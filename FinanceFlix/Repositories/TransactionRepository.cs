using FinanceFlix.Models.Transaction;
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix.Repositories;

public class TransactionRepository : ITransactionRepository
{
    private readonly DBContext _db;

    public TransactionRepository(DBContext db)
    {
        _db = db;

    }

    public async Task<List<Transaction>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _db.Transactions.ToListAsync(cancellationToken);
    }

    public async Task<Transaction> AddAsync(Transaction transaction, CancellationToken cancellationToken = default)
    {
        _db.Transactions.Add(transaction);
        await _db.SaveChangesAsync(cancellationToken);
        return transaction;
    }
}
