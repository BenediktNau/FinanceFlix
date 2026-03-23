using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Accounts.Commands
{
    public class DeleteAccountCommand(int accountId) : IRequest<Result<bool>>
    {
        public int AccountId { get; } = accountId;
    }
}
