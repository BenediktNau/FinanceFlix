namespace FinanceFlix.Repositories.MailInbox;
using FinanceFlix.Models.MailInbox;

public interface IMailInboxRepository
{
    Task<List<MailInbox>> GetAllAsync(CancellationToken ct = default);
    Task<List<MailInbox>> GetByAccountIdAsync(int accountId, CancellationToken ct = default);
    Task<MailInbox> AddAsync(MailInbox inbox, CancellationToken ct = default);
    Task<bool> DeleteAsync(int id, CancellationToken ct = default);
}
