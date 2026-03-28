namespace FinanceFlix.Repositories.TransactionImage;

using FinanceFlix.Models.TransactionImage;

public interface ITransactionImageRepository
{
    Task<TransactionImage?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<List<TransactionImage>> GetByTransactionIdAsync(int transactionId, CancellationToken cancellationToken = default);
    Task<TransactionImage> AddAsync(TransactionImage image, CancellationToken cancellationToken = default);
}
