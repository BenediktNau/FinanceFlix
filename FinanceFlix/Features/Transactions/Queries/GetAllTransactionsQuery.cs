using FinanceFlix.Models;
using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Transactions.Queries
{
    public class GetAllTransactionsQuery : IRequest<Result<List<Transaction>>>
    {

    }
}
