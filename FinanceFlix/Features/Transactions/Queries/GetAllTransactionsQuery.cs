using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Queries
{
    public class GetAllTransactionsQuery(string search) : IRequest<Result<List<Transaction>>>
    {
        public string Search {get; set;} = search;
    }
}
