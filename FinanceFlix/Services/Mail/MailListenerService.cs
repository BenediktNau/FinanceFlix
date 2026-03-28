using System.Text.RegularExpressions;
using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Repositories.MailInbox;
using FinanceFlix.Repositories.Transaction;
using FinanceFlix.Repositories.TransactionImage;
using FinanceFlix.Services.AI;
using MailKit;
using MailKit.Net.Imap;
using MailKit.Security;
using Mediator;
using MimeKit;

namespace FinanceFlix.Services.Mail;

public class MailListenerService : BackgroundService
{
    private static readonly TimeSpan IdleTimeout = TimeSpan.FromMinutes(25);
    private static readonly TimeSpan RetryDelay = TimeSpan.FromSeconds(30);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<MailListenerService> _logger;

    public MailListenerService(IServiceScopeFactory scopeFactory, ILogger<MailListenerService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("MailListenerService starting");

        List<Models.MailInbox.MailInbox> inboxes;
        using (var scope = _scopeFactory.CreateScope())
        {
            var repo = scope.ServiceProvider.GetRequiredService<IMailInboxRepository>();
            inboxes = await repo.GetAllAsync(stoppingToken);
        }

        if (inboxes.Count == 0)
        {
            _logger.LogInformation("No mail inboxes configured, MailListenerService idle");
            return;
        }

        var tasks = inboxes.Select(inbox => ListenToInboxAsync(inbox, stoppingToken));
        await Task.WhenAll(tasks);
    }

    private async Task ListenToInboxAsync(Models.MailInbox.MailInbox inbox, CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            ImapClient? client = null;
            try
            {
                client = new ImapClient();
                var sslOptions = inbox.UseSsl
                    ? SecureSocketOptions.SslOnConnect
                    : SecureSocketOptions.StartTlsWhenAvailable;

                await client.ConnectAsync(inbox.ImapHost, inbox.ImapPort, sslOptions, ct);
                await client.AuthenticateAsync(inbox.Username, inbox.Password, ct);

                _logger.LogInformation("Connected to {DisplayName} ({Host}:{Port})",
                    inbox.DisplayName, inbox.ImapHost, inbox.ImapPort);

                var folder = string.Equals(inbox.FolderName, "INBOX", StringComparison.OrdinalIgnoreCase)
                    ? client.Inbox
                    : await client.GetFolderAsync(inbox.FolderName, ct);

                await folder.OpenAsync(FolderAccess.ReadOnly, ct);
                var previousCount = folder.Count;

                while (!ct.IsCancellationRequested)
                {
                    var newCount = previousCount;
                    using var done = new CancellationTokenSource();
                    EventHandler<EventArgs> handler = (s, _) =>
                    {
                        if (s is IMailFolder f)
                            newCount = f.Count;
                        try { done.Cancel(); } catch { }
                    };

                    folder.CountChanged += handler;
                    try
                    {
                        using var idleTimeout = new CancellationTokenSource(IdleTimeout);
                        using var linked = CancellationTokenSource.CreateLinkedTokenSource(done.Token, idleTimeout.Token);

                        try
                        {
                            await client.IdleAsync(linked.Token, ct);
                        }
                        catch (OperationCanceledException) when (!ct.IsCancellationRequested)
                        {
                            // IDLE ended: either new message arrived, or 25-min timeout — normal
                        }
                    }
                    finally
                    {
                        folder.CountChanged -= handler;
                    }

                    if (newCount > previousCount)
                    {
                        for (var i = previousCount; i < newCount; i++)
                        {
                            try
                            {
                                await OnNewMessageAsync(inbox, folder, i, ct);
                            }
                            catch (Exception ex)
                            {
                                _logger.LogError(ex, "Failed to process message {Index} in {DisplayName}",
                                    i, inbox.DisplayName);
                            }
                        }

                        previousCount = newCount;
                    }
                }
            }
            catch (OperationCanceledException) when (ct.IsCancellationRequested)
            {
                return;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Connection to {DisplayName} failed, retrying in {Delay}s",
                    inbox.DisplayName, RetryDelay.TotalSeconds);

                try
                {
                    await Task.Delay(RetryDelay, ct);
                }
                catch (OperationCanceledException)
                {
                    return;
                }
            }
            finally
            {
                if (client is { IsConnected: true })
                {
                    try
                    {
                        await client.DisconnectAsync(true);
                    }
                    catch
                    {
                        // Best-effort disconnect
                    }
                }

                client?.Dispose();
            }
        }
    }

    private async Task OnNewMessageAsync(
        Models.MailInbox.MailInbox inbox, IMailFolder folder, int messageIndex, CancellationToken ct)
    {
        var message = await folder.GetMessageAsync(messageIndex, ct);

        using var scope = _scopeFactory.CreateScope();
        var categorizer = scope.ServiceProvider.GetRequiredService<ICategorizationService>();
        var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();

        var subject = message.Subject ?? "";
        var (category, amount, description) = await categorizer.CategorizeAsync(
            subject, message.TextBody ?? "", ct);

        var transactionDate = message.Date != DateTimeOffset.MinValue
            ? message.Date.UtcDateTime
            : DateTime.UtcNow;

        var result = await mediator.Send(
            new CreateTransactionCommand(inbox.AccountId, (amount<0? amount : amount*-1), description, category, transactionDate), ct);

        if (!result.IsSuccess)
        {
            _logger.LogError("Failed to create transaction from email '{Subject}': {Error}",
                subject, result.Error);
            return;
        }

        _logger.LogInformation(
            "Created transaction from email '{Subject}' -> {Category} {Amount}",
            description, category, amount);

        // Extract the largest image from the email and attach it to the transaction
        try
        {
            await ExtractAndSaveImagesAsync(message, result.Value!, scope.ServiceProvider, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to extract image from email '{Subject}'", subject);
        }
    }

    private static readonly HttpClient ImageHttpClient = new() { Timeout = TimeSpan.FromSeconds(15) };

    private async Task ExtractAndSaveImagesAsync(
        MimeMessage message, Models.Transaction.Transaction transaction,
        IServiceProvider services, CancellationToken ct)
    {
        var imagesDir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "FinanceFlix", "images");
        Directory.CreateDirectory(imagesDir);

        var imgRepo = services.GetRequiredService<ITransactionImageRepository>();
        var savedCount = 0;

        // 1. Try MIME-attached images first
        foreach (var part in message.BodyParts.OfType<MimePart>())
        {
            if (!part.ContentType.MediaType.Equals("image", StringComparison.OrdinalIgnoreCase))
                continue;

            using var sizeStream = new MemoryStream();
            await part.Content.DecodeToAsync(sizeStream, ct);
            if (sizeStream.Length < 5_000)
                continue;

            var ext = part.ContentType.MediaSubtype.ToLowerInvariant() switch
            {
                "jpeg" => "jpg",
                var s => s
            };
            var filePath = Path.Combine(imagesDir, $"{Guid.NewGuid()}.{ext}");

            await using (var fileStream = File.Create(filePath))
            {
                await part.Content.DecodeToAsync(fileStream, ct);
            }

            await imgRepo.AddAsync(new Models.TransactionImage.TransactionImage
            {
                TransactionId = transaction.Id,
                FilePath = filePath,
                ContentType = $"{part.ContentType.MediaType}/{part.ContentType.MediaSubtype}"
            }, ct);

            savedCount++;
            _logger.LogInformation("Saved MIME image for transaction {Id} ({Size} bytes)", transaction.Id, sizeStream.Length);
        }

        // 2. If no MIME images, try downloading product images from HTML body
        if (savedCount == 0)
        {
            savedCount = await ExtractHtmlImagesAsync(message, transaction, imagesDir, imgRepo, ct);
        }

        if (savedCount == 0)
            _logger.LogInformation("No images found in email for transaction {Id}", transaction.Id);
    }

    private async Task<int> ExtractHtmlImagesAsync(
        MimeMessage message, Models.Transaction.Transaction transaction,
        string imagesDir, ITransactionImageRepository imgRepo, CancellationToken ct)
    {
        var html = message.HtmlBody;
        if (string.IsNullOrEmpty(html))
            return 0;

        // Find <img> tags with src URLs — filter for likely product images
        var imgTags = Regex.Matches(html, @"<img[^>]+src=[""'](?<url>https?://[^""']+)[""'][^>]*>", RegexOptions.IgnoreCase);

        var saved = 0;
        foreach (Match match in imgTags)
        {
            var url = match.Groups["url"].Value.Replace("&amp;", "&");

            // Skip known tracking/UI images
            if (url.Contains("pixel.gif", StringComparison.OrdinalIgnoreCase) ||
                url.Contains("spacer", StringComparison.OrdinalIgnoreCase) ||
                url.Contains("tracker", StringComparison.OrdinalIgnoreCase) ||
                url.Contains("beacon", StringComparison.OrdinalIgnoreCase))
                continue;

            // Check for small dimensions in the tag itself (width/height = 1)
            var tagText = match.Value;
            if (Regex.IsMatch(tagText, @"(?:width|height)\s*=\s*[""']?1[""'\s>]", RegexOptions.IgnoreCase))
                continue;

            // For Amazon, request a larger product image by replacing size suffix
            url = Regex.Replace(url, @"\._[A-Z]{2}\d+_\.", "._SS500_.");

            try
            {
                var response = await ImageHttpClient.GetAsync(url, ct);
                if (!response.IsSuccessStatusCode)
                    continue;

                var contentType = response.Content.Headers.ContentType?.MediaType ?? "image/jpeg";
                if (!contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
                    continue;

                var bytes = await response.Content.ReadAsByteArrayAsync(ct);
                if (bytes.Length < 5_000)
                    continue;

                var ext = contentType.Split('/').Last().ToLowerInvariant() switch
                {
                    "jpeg" => "jpg",
                    var s => s
                };
                var filePath = Path.Combine(imagesDir, $"{Guid.NewGuid()}.{ext}");
                await File.WriteAllBytesAsync(filePath, bytes, ct);

                await imgRepo.AddAsync(new Models.TransactionImage.TransactionImage
                {
                    TransactionId = transaction.Id,
                    FilePath = filePath,
                    ContentType = contentType
                }, ct);

                saved++;
                _logger.LogInformation("Downloaded HTML image for transaction {Id} from {Url} ({Size} bytes)",
                    transaction.Id, url, bytes.Length);
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "Failed to download image from {Url}", url);
            }
        }

        return saved;
    }
}
