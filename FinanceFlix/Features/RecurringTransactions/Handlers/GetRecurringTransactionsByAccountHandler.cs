using FinanceFlix.Features.RecurringTransactions.Queries;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Repositories.RecurringTransaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Handlers;

public class GetRecurringTransactionsByAccountHandler
    : IRequestHandler<GetRecurringTransactionsByAccountQuery, Result<List<RecurringTransaction>>>
{
    private readonly IRecurringTransactionRepository _repo;

    public GetRecurringTransactionsByAccountHandler(IRecurringTransactionRepository repo) => _repo = repo;

    public async ValueTask<Result<List<RecurringTransaction>>> Handle(
        GetRecurringTransactionsByAccountQuery request, CancellationToken ct)
    {
        try
        {
            var list = await _repo.GetByAccountIdAsync(request.AccountId, ct);
            return Result<List<RecurringTransaction>>.Success(list);
        }
        catch (Exception ex)
        {
            return Result<List<RecurringTransaction>>.Failure(ex.Message);
        }
    }
}
