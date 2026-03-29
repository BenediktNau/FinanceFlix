using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Commands;

public class DeleteRecurringTransactionCommand(int id) : IRequest<Result<bool>>
{
    public int Id { get; } = id;
}
