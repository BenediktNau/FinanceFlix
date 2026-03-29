using FinanceFlix.Features.RecurringTransactions.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Repositories.RecurringTransaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Handlers;

public class CreateRecurringTransactionHandler
    : IRequestHandler<CreateRecurringTransactionCommand, Result<RecurringTransaction>>
{
    private readonly IRecurringTransactionRepository _repo;

    public CreateRecurringTransactionHandler(IRecurringTransactionRepository repo) => _repo = repo;

    public async ValueTask<Result<RecurringTransaction>> Handle(
        CreateRecurringTransactionCommand request, CancellationToken ct)
    {
        try
        {
            var entity = new RecurringTransaction
            {
                AccountId = request.AccountId,
                Amount = request.Amount,
                Description = request.Description,
                Category = request.Category,
                Frequency = request.Frequency,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                IsActive = true,
                NextExecutionDate = request.StartDate
            };
            var created = await _repo.AddAsync(entity, ct);
            return Result<RecurringTransaction>.Success(created);
        }
        catch (Exception ex)
        {
            return Result<RecurringTransaction>.Failure(ex.Message);
        }
    }
}
