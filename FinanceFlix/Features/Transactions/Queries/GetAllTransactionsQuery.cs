using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Queries
{
    public class GetAllTransactionsQuery : IRequest<Result<List<Transaction>>>
    {

    }
}
