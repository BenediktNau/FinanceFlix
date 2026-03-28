namespace FinanceFlix.Repositories.TransactionImage;

using Microsoft.EntityFrameworkCore;
using FinanceFlix.Models.TransactionImage;

public class TransactionImageRepository : ITransactionImageRepository
{
    private readonly DBContext _db;

    public TransactionImageRepository(DBContext db)
    {
        _db = db;
    }

    public async Task<TransactionImage?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _db.TransactionImages.FindAsync([id], cancellationToken);
    }

    public async Task<List<TransactionImage>> GetByTransactionIdAsync(int transactionId, CancellationToken cancellationToken = default)
    {
        return await _db.TransactionImages
            .Where(i => i.TransactionId == transactionId)
            .ToListAsync(cancellationToken);
    }

    public async Task<TransactionImage> AddAsync(TransactionImage image, CancellationToken cancellationToken = default)
    {
        _db.TransactionImages.Add(image);
        await _db.SaveChangesAsync(cancellationToken);
        return image;
    }
}
