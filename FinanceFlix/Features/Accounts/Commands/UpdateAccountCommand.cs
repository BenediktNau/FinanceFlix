using FinanceFlix.Models.Account;
using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Accounts.Commands
{
    public class UpdateAccountCommand(
        int accountId,
        string accountName,
        decimal balance) : IRequest<Result<Account>>
    {
        public int AccountId { get; } = accountId;
        public string AccountName { get; } = accountName;
        public decimal Balance { get; } = balance;
    }
}
