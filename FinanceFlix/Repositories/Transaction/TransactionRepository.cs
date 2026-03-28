
namespace FinanceFlix.Repositories.Transaction;


using Microsoft.EntityFrameworkCore;

using FinanceFlix.Models.Transaction;
public class TransactionRepository : ITransactionRepository
{
    private readonly DBContext _db;

    public TransactionRepository(DBContext db)
    {
        _db = db;

    }

    public async Task<List<Transaction>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _db.Transactions.Include(t => t.Images).ToListAsync(cancellationToken);
    }

    public async Task<Transaction?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _db.Transactions.FindAsync([id], cancellationToken);
    }

    public async Task<Transaction> AddAsync(Transaction transaction, CancellationToken cancellationToken = default)
    {
        _db.Transactions.Add(transaction);
        await _db.SaveChangesAsync(cancellationToken);
        return transaction;
    }

    public async Task<Transaction?> UpdateAsync(Transaction transaction, CancellationToken cancellationToken = default)
    {
        var existing = await _db.Transactions.FindAsync([transaction.Id], cancellationToken);
        if (existing is null) return null;

        existing.Amount = transaction.Amount;
        existing.Category = transaction.Category;
        existing.Date = transaction.Date;
        await _db.SaveChangesAsync(cancellationToken);
        return existing;
    }

    public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var transaction = await _db.Transactions.FindAsync([id], cancellationToken);
        if (transaction is null) return false;

        _db.Transactions.Remove(transaction);
        return (await _db.SaveChangesAsync(cancellationToken)) == 1;
    }
}
