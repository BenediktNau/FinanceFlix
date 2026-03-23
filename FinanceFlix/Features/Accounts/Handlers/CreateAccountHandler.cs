using FinanceFlix.Features.Accounts.Commands;
using FinanceFlix.Models.Account;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Account;
using Mediator;

namespace FinanceFlix.Features.Accounts.Handlers
{
    public class CreateAccountHandler : IRequestHandler<CreateAccountCommand, Result<bool>>
    {
        private readonly IAccountRepository _repository;

        public CreateAccountHandler(IAccountRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<bool>> Handle(
            CreateAccountCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var account = new Account
                {
                    UserId = request.UserId,
                    AccountName = request.AccountName,
                    Balance = request.Balance
                };
                var created = await _repository.CreateAccountAsync(account, cancellationToken);
                return Result<bool>.Success(created);
            }
            catch (Exception ex)
            {
                return Result<bool>.Failure(ex.Message);
            }
        }
    }
}
