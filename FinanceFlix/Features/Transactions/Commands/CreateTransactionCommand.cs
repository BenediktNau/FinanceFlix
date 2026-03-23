using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Commands
{
    public class CreateTransactionCommand(
        int accountId,
        decimal amount,
        TransactionCategory category,
        DateTime date) : IRequest<Result<Transaction>>
    {
        public int AccountId { get; } = accountId;
        public decimal Amount { get; } = amount;
        public TransactionCategory Category { get; } = category;
        public DateTime Date { get; } = date;
    }
}
