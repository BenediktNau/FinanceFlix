using RecurringTransactionModel = FinanceFlix.Models.RecurringTransaction.RecurringTransaction;

namespace FinanceFlix.Repositories.RecurringTransaction;

public interface IRecurringTransactionRepository
{
    Task<List<RecurringTransactionModel>> GetByAccountIdAsync(int accountId, CancellationToken ct = default);
    Task<RecurringTransactionModel?> GetByIdAsync(int id, CancellationToken ct = default);
    Task<List<RecurringTransactionModel>> GetDueAsync(CancellationToken ct = default);
    Task<RecurringTransactionModel> AddAsync(RecurringTransactionModel entity, CancellationToken ct = default);
    Task<RecurringTransactionModel?> UpdateAsync(RecurringTransactionModel entity, CancellationToken ct = default);
    Task<bool> DeleteAsync(int id, CancellationToken ct = default);
}
