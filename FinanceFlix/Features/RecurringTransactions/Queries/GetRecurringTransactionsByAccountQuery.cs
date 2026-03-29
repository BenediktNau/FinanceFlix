using FinanceFlix.Models.Common;
using FinanceFlix.Models.RecurringTransaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Queries;

public class GetRecurringTransactionsByAccountQuery(int accountId)
    : IRequest<Result<List<RecurringTransaction>>>
{
    public int AccountId { get; } = accountId;
}
