using Microsoft.EntityFrameworkCore;
using RecurringTransactionModel = FinanceFlix.Models.RecurringTransaction.RecurringTransaction;

namespace FinanceFlix.Repositories.RecurringTransaction;

public class RecurringTransactionRepository : IRecurringTransactionRepository
{
    private readonly DBContext _db;

    public RecurringTransactionRepository(DBContext db) => _db = db;

    public async Task<List<RecurringTransactionModel>> GetByAccountIdAsync(int accountId, CancellationToken ct = default)
        => await _db.RecurringTransactions.Where(r => r.AccountId == accountId).ToListAsync(ct);

    public async Task<RecurringTransactionModel?> GetByIdAsync(int id, CancellationToken ct = default)
        => await _db.RecurringTransactions.FindAsync([id], ct);

    public async Task<List<RecurringTransactionModel>> GetDueAsync(CancellationToken ct = default)
        => await _db.RecurringTransactions
            .Where(r => r.IsActive && r.NextExecutionDate <= DateTime.UtcNow &&
                        (r.EndDate == null || r.EndDate >= DateTime.UtcNow))
            .ToListAsync(ct);

    public async Task<RecurringTransactionModel> AddAsync(RecurringTransactionModel entity, CancellationToken ct = default)
    {
        _db.RecurringTransactions.Add(entity);
        await _db.SaveChangesAsync(ct);
        return entity;
    }

    public async Task<RecurringTransactionModel?> UpdateAsync(RecurringTransactionModel entity, CancellationToken ct = default)
    {
        var existing = await _db.RecurringTransactions.FindAsync([entity.Id], ct);
        if (existing is null) return null;

        existing.Amount = entity.Amount;
        existing.Description = entity.Description;
        existing.Category = entity.Category;
        existing.Frequency = entity.Frequency;
        existing.StartDate = entity.StartDate;
        existing.EndDate = entity.EndDate;
        existing.IsActive = entity.IsActive;
        existing.NextExecutionDate = entity.NextExecutionDate;
        await _db.SaveChangesAsync(ct);
        return existing;
    }

    public async Task<bool> DeleteAsync(int id, CancellationToken ct = default)
    {
        var entity = await _db.RecurringTransactions.FindAsync([id], ct);
        if (entity is null) return false;
        _db.RecurringTransactions.Remove(entity);
        return (await _db.SaveChangesAsync(ct)) == 1;
    }
}
