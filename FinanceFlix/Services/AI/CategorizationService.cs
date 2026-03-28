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

    public async Task<(TransactionCategory Category, decimal Amount, string Description)> CategorizeAsync(string subject, string body, CancellationToken ct = default)
    {
        var cleanedBody = CleanEmailBody(body);

        var prompt = $$"""
            You are a financial transaction categorizer. Analyze the email below and extract exactly three fields.

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
            - "amount": the final total the customer paid as a decimal (e.g. 29.99). Use the amount after tax/VAT if shown.
            - "description": try to name the specific item(s) or service purchased (e.g. "RV There Yet? (Steam)" not "Steam game purchase receipt"). Always include the actual product name if mentioned in the email. Additional Add 1-2 simple, short Sentences to this product(s).
            - If the email is not a receipt or bill, use category "Other", amount 0.00, and describe what the email is about.

            EMAIL SUBJECT: {{subject}}
            EMAIL BODY:
            {{cleanedBody}}

            Respond with ONLY valid JSON, no extra text:
            {"category": "...", "amount": 0.00, "description": "..."}
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
            return (TransactionCategory.Other, 0m, "JSON Matching gone wrong");

        var result = JsonSerializer.Deserialize<CategorizationResult>(jsonMatch.Value, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (result is null)
            return (TransactionCategory.Other, 0m, "No Result");

        if (Enum.TryParse<TransactionCategory>(result.Category, ignoreCase: true, out var category))
            return (category, result.Amount, result.Description);

        return (TransactionCategory.Other, result.Amount, result.Description);
    }
}

internal class CategorizationResult
{
    public string Category { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Description { get; set; } = string.Empty;
}
