using FinanceFlix.Features.RecurringTransactions.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.RecurringTransaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Handlers;

public class DeleteRecurringTransactionHandler
    : IRequestHandler<DeleteRecurringTransactionCommand, Result<bool>>
{
    private readonly IRecurringTransactionRepository _repo;

    public DeleteRecurringTransactionHandler(IRecurringTransactionRepository repo) => _repo = repo;

    public async ValueTask<Result<bool>> Handle(
        DeleteRecurringTransactionCommand request, CancellationToken ct)
    {
        try
        {
            var deleted = await _repo.DeleteAsync(request.Id, ct);
            return deleted
                ? Result<bool>.Success(true)
                : Result<bool>.Failure("Recurring transaction not found");
        }
        catch (Exception ex)
        {
            return Result<bool>.Failure(ex.Message);
        }
    }
}
