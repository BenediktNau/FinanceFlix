using FinanceFlix.Models.Common;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Commands;

public class CreateRecurringTransactionCommand(
    int accountId, decimal amount, string description,
    TransactionCategory category, RecurrenceFrequency frequency,
    DateTime startDate, DateTime? endDate) : IRequest<Result<RecurringTransaction>>
{
    public int AccountId { get; } = accountId;
    public decimal Amount { get; } = amount;
    public string Description { get; } = description;
    public TransactionCategory Category { get; } = category;
    public RecurrenceFrequency Frequency { get; } = frequency;
    public DateTime StartDate { get; } = startDate;
    public DateTime? EndDate { get; } = endDate;
}
