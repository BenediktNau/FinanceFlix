using FinanceFlix.Models.Transaction;

namespace FinanceFlix.Repositories;

public interface ITransactionRepository
{
    Task<List<Transaction>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<Transaction> AddAsync(Transaction transaction, CancellationToken cancellationToken = default);
}
