using FinanceFlix.Features.Accounts.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Account;
using Mediator;

namespace FinanceFlix.Features.Accounts.Handlers
{
    public class DeleteAccountHandler : IRequestHandler<DeleteAccountCommand, Result<bool>>
    {
        private readonly IAccountRepository _repository;

        public DeleteAccountHandler(IAccountRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<bool>> Handle(
            DeleteAccountCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var deleted = await _repository.DeleteAsync(request.AccountId, cancellationToken);
                return deleted
                    ? Result<bool>.Success(true)
                    : Result<bool>.Failure($"Account {request.AccountId} not found.");
            }
            catch (Exception ex)
            {
                return Result<bool>.Failure(ex.Message);
            }
        }
    }
}
