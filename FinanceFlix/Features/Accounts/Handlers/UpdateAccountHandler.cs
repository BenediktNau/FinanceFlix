using FinanceFlix.Features.Accounts.Commands;
using FinanceFlix.Models.Account;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Account;
using Mediator;

namespace FinanceFlix.Features.Accounts.Handlers
{
    public class UpdateAccountHandler : IRequestHandler<UpdateAccountCommand, Result<Account>>
    {
        private readonly IAccountRepository _repository;

        public UpdateAccountHandler(IAccountRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<Account>> Handle(
            UpdateAccountCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var updated = await _repository.UpdateAsync(new Account
                {
                    AccountId = request.AccountId,
                    AccountName = request.AccountName,
                    Balance = request.Balance
                }, cancellationToken);

                return updated is not null
                    ? Result<Account>.Success(updated)
                    : Result<Account>.Failure($"Account {request.AccountId} not found.");
            }
            catch (Exception ex)
            {
                return Result<Account>.Failure(ex.Message);
            }
        }
    }
}
