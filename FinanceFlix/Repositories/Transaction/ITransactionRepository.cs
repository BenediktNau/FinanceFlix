namespace FinanceFlix.Repositories.Transaction;
using FinanceFlix.Models.Transaction;

public interface ITransactionRepository
{
    Task<List<Transaction>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<Transaction?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<Transaction> AddAsync(Transaction transaction, CancellationToken cancellationToken = default);
    Task<Transaction?> UpdateAsync(Transaction transaction, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
}
