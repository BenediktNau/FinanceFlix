using FinanceFlix.Models.Account;
using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Accounts.Queries
{
    public class GetAccountsQuery(string userId) : IRequest<Result<List<Account>>>
    {
        public string UserId { get; } = userId;
    }
}
