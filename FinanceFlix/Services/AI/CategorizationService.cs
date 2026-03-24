using System.Text.Json;
using System.Text.RegularExpressions;
using FinanceFlix.Models.Transaction;
using OllamaSharp;
using OllamaSharp.Models;

namespace FinanceFlix.Services.AI;

public class CategorizationService : ICategorizationService
{
    private readonly OllamaApiClient _ollama;

    public CategorizationService(IConfiguration config)
    {
        var host = config["Ollama:Host"] ?? "http://localhost:11434";
        var model = config["Ollama:Model"] ?? "llama3.2";
        _ollama = new OllamaApiClient(host) { SelectedModel = model };
    }

    public async Task<(TransactionCategory Category, decimal Amount)> CategorizeAsync(string subject, string body, CancellationToken ct = default)
    {
        var categories = string.Join(", ", Enum.GetNames<TransactionCategory>());

        var prompt = $$"""
            You are a financial transaction categorizer for a German finance app.
            Given this bill/receipt email, extract:
            1. The category (must be exactly one of: {{categories}})
            2. The total amount as a decimal number (e.g. 29.99)

            Email Subject: {{subject}}
            Email Body: {{body}}

            Respond ONLY with valid JSON, nothing else: {"category": "...", "amount": 0.00}
            """;

        var request = new GenerateRequest
        {
            Model = _ollama.SelectedModel,
            Prompt = prompt,
            Stream = false,
            Format = "json"
        };

        var responseText = string.Empty;

        await foreach (var chunk in _ollama.GenerateAsync(request, ct))
        {
            if (chunk?.Response is not null)
                responseText += chunk.Response;
        }

        // Extract JSON from response (in case the model wraps it in extra text)
        var jsonMatch = Regex.Match(responseText, @"\{[^}]*\}");
        if (!jsonMatch.Success)
            return (TransactionCategory.Sonstiges, 0m);

        var result = JsonSerializer.Deserialize<CategorizationResult>(jsonMatch.Value, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (result is null)
            return (TransactionCategory.Sonstiges, 0m);

        if (Enum.TryParse<TransactionCategory>(result.Category, ignoreCase: true, out var category))
            return (category, result.Amount);

        return (TransactionCategory.Sonstiges, result.Amount);
    }
}

internal class CategorizationResult
{
    public string Category { get; set; } = string.Empty;
    public decimal Amount { get; set; }
}
