using FinanceFlix.Features.Transactions.Queries;
using FinanceFlix.Models;
using FinanceFlix.Models.Common;
using Mediator;
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix.Features.Transactions.Handlers
{
    public class GetAllTransactionsHandler : IRequestHandler<GetAllTransactionsQuery, Result<List<Transaction>>>
    {
        private readonly DBContext _db;

        public GetAllTransactionsHandler(DBContext db)
        {
            _db = db;
        }

        public async ValueTask<Result<List<Transaction>>> Handle(
         GetAllTransactionsQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var transactions = await _db.Transactions.ToListAsync(cancellationToken);
                return Result<List<Transaction>>.Success(transactions);
            }
            catch (Exception ex)
            {
                return Result<List<Transaction>>.Failure(ex.Message);
            }
        }


    }
}
