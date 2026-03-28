using FinanceFlix.Models.Transaction;

namespace FinanceFlix.Services.AI;

public interface ICategorizationService
{
    Task<(TransactionCategory Category, decimal Amount, string Description)> CategorizeAsync(string subject, string body, CancellationToken ct = default);
}