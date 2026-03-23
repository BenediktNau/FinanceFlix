using FinanceFlix.Features.Accounts.Queries;
using FinanceFlix.Models.Account;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Account;
using Mediator;

namespace FinanceFlix.Features.Accounts.Handlers
{
    public class GetAccountsHandler : IRequestHandler<GetAccountsQuery, Result<List<Account>>>
    {
        private readonly IAccountRepository _repository;

        public GetAccountsHandler(IAccountRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<List<Account>>> Handle(
            GetAccountsQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var accounts = await _repository.GetAccountsAsync(request.UserId, cancellationToken);
                return Result<List<Account>>.Success(accounts);
            }
            catch (Exception ex)
            {
                return Result<List<Account>>.Failure(ex.Message);
            }
        }
    }
}
