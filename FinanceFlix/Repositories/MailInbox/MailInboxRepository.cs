using Microsoft.EntityFrameworkCore;

namespace FinanceFlix.Repositories.MailInbox;

public class MailInboxRepository : IMailInboxRepository
{
    readonly DBContext _db;

    public MailInboxRepository(DBContext db)
    {
        _db = db;
    }

    public async Task<List<Models.MailInbox.MailInbox>> GetAllAsync(CancellationToken ct = default)
    {
        return await _db.MailInboxes.ToListAsync(ct);
    }

    public async Task<List<Models.MailInbox.MailInbox>> GetByAccountIdAsync(int accountId, CancellationToken ct = default)
    {
        return await _db.MailInboxes.Where(e => e.AccountId == accountId).ToListAsync(ct);
    }

    public async Task<Models.MailInbox.MailInbox> AddAsync(Models.MailInbox.MailInbox inbox, CancellationToken ct = default)
    {
        _db.MailInboxes.Add(inbox);
        await _db.SaveChangesAsync(ct);
        return inbox;
    }

    public async Task<bool> DeleteAsync(int id, CancellationToken ct = default)
    {
        var inbox = await _db.MailInboxes.FindAsync([id], ct);
        if (inbox is null) return false;

        _db.MailInboxes.Remove(inbox);
        return (await _db.SaveChangesAsync(ct)) == 1;
    }
}
