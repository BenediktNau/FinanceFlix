using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using FinanceFlix.Repositories.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Handlers
{
    public class CreateTransactionHandler : IRequestHandler<CreateTransactionCommand, Result<Transaction>>
    {
        private readonly ITransactionRepository _repository;

        public CreateTransactionHandler(ITransactionRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<Transaction>> Handle(
            CreateTransactionCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var transaction = new Transaction
                {
                    AccountId = request.AccountId,
                    Amount = request.Amount,
                    Description = request.Description,
                    Category = request.Category,
                    Date = request.Date
                };
                var created = await _repository.AddAsync(transaction, cancellationToken);
                return Result<Transaction>.Success(created);
            }
            catch (Exception ex)
            {
                return Result<Transaction>.Failure(ex.Message);
            }
        }
    }
}
