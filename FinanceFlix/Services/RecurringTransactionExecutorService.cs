using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Repositories.RecurringTransaction;
using Mediator;

namespace FinanceFlix.Services;

public class RecurringTransactionExecutorService : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromHours(1);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<RecurringTransactionExecutorService> _logger;

    public RecurringTransactionExecutorService(
        IServiceScopeFactory scopeFactory, ILogger<RecurringTransactionExecutorService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("RecurringTransactionExecutorService started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ExecuteDueTransactionsAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                _logger.LogError(ex, "Error executing recurring transactions");
            }

            try
            {
                await Task.Delay(Interval, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                return;
            }
        }
    }

    private async Task ExecuteDueTransactionsAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IRecurringTransactionRepository>();
        var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();

        var due = await repo.GetDueAsync(ct);
        if (due.Count == 0) return;

        _logger.LogInformation("Found {Count} recurring transactions due for execution", due.Count);

        foreach (var recurring in due)
        {
            try
            {
                var result = await mediator.Send(
                    new CreateTransactionCommand(
                        recurring.AccountId,
                        recurring.Amount,
                        recurring.Description,
                        recurring.Category,
                        recurring.NextExecutionDate),
                    ct);

                if (result.IsSuccess)
                {
                    recurring.NextExecutionDate = CalculateNextDate(recurring.NextExecutionDate, recurring.Frequency);

                    // Deactivate if past end date
                    if (recurring.EndDate.HasValue && recurring.NextExecutionDate > recurring.EndDate.Value)
                        recurring.IsActive = false;

                    await repo.UpdateAsync(recurring, ct);

                    _logger.LogInformation(
                        "Executed recurring transaction {Id} '{Desc}' -> next: {Next}",
                        recurring.Id, recurring.Description, recurring.NextExecutionDate);
                }
                else
                {
                    _logger.LogError("Failed to execute recurring transaction {Id}: {Error}",
                        recurring.Id, result.Error);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing recurring transaction {Id}", recurring.Id);
            }
        }
    }

    internal static DateTime CalculateNextDate(DateTime current, RecurrenceFrequency frequency)
    {
        return frequency switch
        {
            RecurrenceFrequency.Daily => current.AddDays(1),
            RecurrenceFrequency.Weekly => current.AddDays(7),
            RecurrenceFrequency.BiWeekly => current.AddDays(14),
            RecurrenceFrequency.Monthly => current.AddMonths(1),
            RecurrenceFrequency.Quarterly => current.AddMonths(3),
            RecurrenceFrequency.Yearly => current.AddYears(1),
            _ => current.AddMonths(1)
        };
    }
}
