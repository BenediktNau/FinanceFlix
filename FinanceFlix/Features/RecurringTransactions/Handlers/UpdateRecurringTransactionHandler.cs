using FinanceFlix.Features.RecurringTransactions.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Repositories.RecurringTransaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Handlers;

public class UpdateRecurringTransactionHandler
    : IRequestHandler<UpdateRecurringTransactionCommand, Result<RecurringTransaction>>
{
    private readonly IRecurringTransactionRepository _repo;

    public UpdateRecurringTransactionHandler(IRecurringTransactionRepository repo) => _repo = repo;

    public async ValueTask<Result<RecurringTransaction>> Handle(
        UpdateRecurringTransactionCommand request, CancellationToken ct)
    {
        try
        {
            var entity = new RecurringTransaction
            {
                Id = request.Id,
                Amount = request.Amount,
                Description = request.Description,
                Category = request.Category,
                Frequency = request.Frequency,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                IsActive = request.IsActive,
                NextExecutionDate = request.StartDate
            };
            var updated = await _repo.UpdateAsync(entity, ct);
            return updated is not null
                ? Result<RecurringTransaction>.Success(updated)
                : Result<RecurringTransaction>.Failure("Recurring transaction not found");
        }
        catch (Exception ex)
        {
            return Result<RecurringTransaction>.Failure(ex.Message);
        }
    }
}
