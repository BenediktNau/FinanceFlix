using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Handlers
{
    public class DeleteTransactionHandler : IRequestHandler<DeleteTransactionCommand, Result<bool>>
    {
        private readonly ITransactionRepository _repository;

        public DeleteTransactionHandler(ITransactionRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<bool>> Handle(
            DeleteTransactionCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var deleted = await _repository.DeleteAsync(request.Id, cancellationToken);
                return deleted
                    ? Result<bool>.Success(true)
                    : Result<bool>.Failure($"Transaction {request.Id} not found.");
            }
            catch (Exception ex)
            {
                return Result<bool>.Failure(ex.Message);
            }
        }
    }
}
