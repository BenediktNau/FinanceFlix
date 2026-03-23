using FinanceFlix.Features.Transactions.Queries;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using FinanceFlix.Repositories.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Handlers
{
    public class GetAllTransactionsHandler : IRequestHandler<GetAllTransactionsQuery, Result<List<Transaction>>>
    {
        private readonly ITransactionRepository _repository;

        public GetAllTransactionsHandler(ITransactionRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<List<Transaction>>> Handle(
         GetAllTransactionsQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var transactions = await _repository.GetAllAsync(cancellationToken);
                return Result<List<Transaction>>.Success(transactions);
            }
            catch (Exception ex)
            {
                return Result<List<Transaction>>.Failure(ex.Message);
            }
        }
    }
}
