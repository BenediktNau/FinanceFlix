using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using FinanceFlix.Repositories.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Handlers
{
    public class UpdateTransactionHandler : IRequestHandler<UpdateTransactionCommand, Result<Transaction>>
    {
        private readonly ITransactionRepository _repository;

        public UpdateTransactionHandler(ITransactionRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<Transaction>> Handle(
            UpdateTransactionCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var updated = await _repository.UpdateAsync(new Transaction
                {
                    Id = request.Id,
                    Amount = request.Amount,
                    Description = request.Description,
                    Category = request.Category,
                    Date = request.Date
                }, cancellationToken);

                return updated is not null
                    ? Result<Transaction>.Success(updated)
                    : Result<Transaction>.Failure($"Transaction {request.Id} not found.");
            }
            catch (Exception ex)
            {
                return Result<Transaction>.Failure(ex.Message);
            }
        }
    }
}
