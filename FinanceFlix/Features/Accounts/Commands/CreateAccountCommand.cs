using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Accounts.Commands
{
    public class CreateAccountCommand(
        string userId,
        string accountName,
        decimal balance) : IRequest<Result<bool>>
    {
        public string UserId { get; } = userId;
        public string AccountName { get; } = accountName;
        public decimal Balance { get; } = balance;
    }
}
