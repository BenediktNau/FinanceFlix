using FinanceFlix.Models.Common;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.RecurringTransactions.Commands;

public class UpdateRecurringTransactionCommand(
    int id, decimal amount, string description,
    TransactionCategory category, RecurrenceFrequency frequency,
    DateTime startDate, DateTime? endDate, bool isActive) : IRequest<Result<RecurringTransaction>>
{
    public int Id { get; } = id;
    public decimal Amount { get; } = amount;
    public string Description { get; } = description;
    public TransactionCategory Category { get; } = category;
    public RecurrenceFrequency Frequency { get; } = frequency;
    public DateTime StartDate { get; } = startDate;
    public DateTime? EndDate { get; } = endDate;
    public bool IsActive { get; } = isActive;
}
