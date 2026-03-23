
namespace FinanceFlix.Repositories.Account
{
    using FinanceFlix.Models.Account;

    public interface IAccountRepository
    {
        Task<List<Account>> GetAccountsAsync(string userId, CancellationToken cancellationToken = default);
        Task<Account?> GetByIdAsync(int accountId, CancellationToken cancellationToken = default);
        Task<bool> CreateAccountAsync(Account creationAccount, CancellationToken cancellationToken = default);
        Task<Account?> UpdateAsync(Account account, CancellationToken cancellationToken = default);
        Task<bool> DeleteAsync(int accountId, CancellationToken cancellationToken = default);
    }
}
