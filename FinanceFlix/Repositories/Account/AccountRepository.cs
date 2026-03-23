
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix.Repositories.Account
{
    public class AccountRepository : IAccountRepository
    {
        readonly DBContext _db;

        public AccountRepository(DBContext db)
        {
            _db = db;
        }

        public async Task<List<Models.Account.Account>> GetAccountsAsync(string userId, CancellationToken cancellationToken = default)
        {
            return await _db.Accounts.Where(e => e.UserId.Equals(userId)).ToListAsync(cancellationToken);
        }

        public async Task<Models.Account.Account?> GetByIdAsync(int accountId, CancellationToken cancellationToken = default)
        {
            return await _db.Accounts.FindAsync([accountId], cancellationToken);
        }

        public async Task<bool> CreateAccountAsync(Models.Account.Account creationAccount, CancellationToken cancellationToken = default)
        {
            _db.Accounts.Add(creationAccount);
            return (await _db.SaveChangesAsync(cancellationToken)) == 1;
        }

        public async Task<Models.Account.Account?> UpdateAsync(Models.Account.Account account, CancellationToken cancellationToken = default)
        {
            var existing = await _db.Accounts.FindAsync([account.AccountId], cancellationToken);
            if (existing is null) return null;

            existing.AccountName = account.AccountName;
            existing.Balance = account.Balance;
            await _db.SaveChangesAsync(cancellationToken);
            return existing;
        }

        public async Task<bool> DeleteAsync(int accountId, CancellationToken cancellationToken = default)
        {
            var account = await _db.Accounts.FindAsync([accountId], cancellationToken);
            if (account is null) return false;

            _db.Accounts.Remove(account);
            return (await _db.SaveChangesAsync(cancellationToken)) == 1;
        }
    }
}
