using System.Text.Json;
using System.Text.RegularExpressions;
using FinanceFlix.Models.Transaction;
using OllamaSharp;
using OllamaSharp.Models;

namespace FinanceFlix.Services.AI;

public class CategorizationService : ICategorizationService
{
    private readonly OllamaApiClient _ollama;
    private readonly ILogger<CategorizationService> _logger;

    public CategorizationService(IConfiguration config, ILogger<CategorizationService> logger)
    {
        var host = config["Ollama:Host"] ?? "http://localhost:11434";
        var model = config["Ollama:Model"] ?? "gemma3:4b";
        var httpClient = new HttpClient { BaseAddress = new Uri(host), Timeout = TimeSpan.FromMinutes(5) };
        _ollama = new OllamaApiClient(httpClient) { SelectedModel = model };
        _logger = logger;
    }

    private static string CleanEmailBody(string body)
    {
        // Remove forwarding header blocks
        var cleaned = Regex.Replace(body, @"-{5,}\s*Forwarded message\s*-{5,}", "", RegexOptions.IgnoreCase);
        // Remove forwarding metadata lines (Von/From, Date, To) but keep Subject
        cleaned = Regex.Replace(cleaned, @"^(Von|From|To|Date|Datum|An):.*$", "", RegexOptions.Multiline | RegexOptions.IgnoreCase);
        // Remove URLs
        cleaned = Regex.Replace(cleaned, @"https?://\S+", "");
        // Remove image/link markers like [image: Steam]
        cleaned = Regex.Replace(cleaned, @"\[image:[^\]]*\]", "");
        // Remove lines that are just whitespace or asterisks
        cleaned = Regex.Replace(cleaned, @"^\s*\*?\s*$", "", RegexOptions.Multiline);
        // Collapse 3+ consecutive newlines into 2
        cleaned = Regex.Replace(cleaned, @"(\r?\n\s*){3,}", "\n\n");
        // Truncate to 2000 chars
        if (cleaned.Length > 2000)
            cleaned = cleaned[..2000];
        return cleaned.Trim();
    }

    /// <summary>
    /// Extracts the total amount from an email using regex.
    /// Looks for a "Total" line first, then falls back to summing all prices.
    /// </summary>
    private decimal? ExtractAmountFromText(string text)
    {
        // Price pattern: currency symbol + digits with decimal (e.g. €36.88, $29.99, £12,50)
        // Also handles: 36.88€, 36,88 EUR, EUR 36.88
        const string decimalPrice =
            @"(?:[\€\$£]\s?)(\d{1,6}[.,]\d{2})" +   // €36.88 or € 36,88
            @"|(\d{1,6}[.,]\d{2})\s?(?:[\€\$£]|EUR|USD|GBP)"; // 36.88€ or 36.88 EUR

        // 1. Look for a "total" line — most reliable
        var totalMatch = Regex.Match(text,
            @"(?:Total|Gesamt|Summe|Order\s*Total|Grand\s*Total|Gesamtbetrag)[:\s]*(?:[\€\$£]\s?)(\d{1,6}[.,]\d{2})|" +
            @"(?:Total|Gesamt|Summe|Order\s*Total|Grand\s*Total|Gesamtbetrag)[:\s]*(\d{1,6}[.,]\d{2})\s?(?:[\€\$£]|EUR|USD|GBP)",
            RegexOptions.IgnoreCase);

        if (totalMatch.Success)
        {
            var totalStr = totalMatch.Groups.Cast<Group>()
                .Skip(1)
                .FirstOrDefault(g => g.Success)?.Value;

            if (totalStr != null && TryParsePrice(totalStr, out var total))
            {
                _logger.LogInformation("Regex extracted total amount: {Amount}", total);
                return total;
            }
        }

        // 2. No total found — sum all properly formatted prices
        var prices = new List<decimal>();
        foreach (Match m in Regex.Matches(text, decimalPrice))
        {
            var priceStr = m.Groups.Cast<Group>()
                .Skip(1)
                .FirstOrDefault(g => g.Success)?.Value;

            if (priceStr != null && TryParsePrice(priceStr, out var price))
                prices.Add(price);
        }

        if (prices.Count > 0)
        {
            var sum = prices.Sum();
            _logger.LogInformation("Regex extracted {Count} prices, sum: {Amount}", prices.Count, sum);
            return sum;
        }

        return null;
    }

    private static bool TryParsePrice(string priceStr, out decimal result)
    {
        // Normalize: replace comma decimal separator with dot
        var normalized = priceStr.Replace(',', '.');
        return decimal.TryParse(normalized, System.Globalization.NumberStyles.AllowDecimalPoint,
            System.Globalization.CultureInfo.InvariantCulture, out result);
    }

    public async Task<(TransactionCategory Category, decimal Amount, string Description)> CategorizeAsync(string subject, string body, CancellationToken ct = default)
    {
        var cleanedBody = CleanEmailBody(body);

        // Extract amount via regex first — much more reliable than AI for numbers
        var regexAmount = ExtractAmountFromText(body) ?? ExtractAmountFromText(subject);

        var prompt = $$"""
            You are a financial transaction categorizer. Analyze the email below and extract exactly two fields.

            CATEGORIES (pick exactly one):
            - Income: salary, wages, refunds, reimbursements, interest, dividends
            - Housing: rent, mortgage, utilities, electricity, water, internet, insurance
            - Groceries: supermarket, food, beverages, household supplies
            - Transport: fuel, public transit, car maintenance, ride-sharing, parking, flights
            - Entertainment: games, streaming, movies, music, concerts, hobbies, subscriptions (Netflix, Steam, Spotify, etc.)
            - Health: pharmacy, doctor, dentist, gym, medical insurance
            - Shopping: clothing, electronics, furniture, online retail (Amazon, etc.)
            - Savings: transfers to savings accounts, investments
            - Other: anything that does not clearly fit the above

            RULES:
            - "category": use exactly one of the category names above (e.g. "Entertainment", not "entertainment").
            - "description": List ALL items or services purchased, separated by " + " (e.g. "Anker Nano 65W USB C Charger + VARTA AAA Rechargeable Batteries"). Always include every product name mentioned in the email. Keep each item name short but recognizable.
            - If the email is not a receipt or bill, use category "Other" and describe what the email is about.

            EMAIL SUBJECT: {{subject}}
            EMAIL BODY:
            {{cleanedBody}}

            Respond with ONLY valid JSON, no extra text:
            {"category": "...", "description": "..."}
            """;

        var request = new GenerateRequest
        {
            Model = _ollama.SelectedModel,
            Prompt = prompt,
            Stream = false,
            Format = "json"
        };

        _logger.Log(LogLevel.Information, "This is the prompt: {Prompt}", prompt);

        var responseText = string.Empty;

        await foreach (var chunk in _ollama.GenerateAsync(request, ct))
        {
            if (chunk?.Response is not null)
                responseText += chunk.Response;
        }

        // Extract JSON from response (in case the model wraps it in extra text)
        var jsonMatch = Regex.Match(responseText, @"\{[^}]*\}");
        if (!jsonMatch.Success)
            return (TransactionCategory.Other, regexAmount ?? 0m, "JSON Matching gone wrong");

        var result = JsonSerializer.Deserialize<CategorizationResult>(jsonMatch.Value, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (result is null)
            return (TransactionCategory.Other, regexAmount ?? 0m, "No Result");

        // Use regex amount if available, otherwise fall back to AI amount
        var amount = regexAmount ?? result.Amount;

        if (Enum.TryParse<TransactionCategory>(result.Category, ignoreCase: true, out var category))
            return (category, amount, result.Description);

        return (TransactionCategory.Other, amount, result.Description);
    }
}

internal class CategorizationResult
{
    public string Category { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Description { get; set; } = string.Empty;
}
