using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Commands
{
    public class UpdateTransactionCommand(
        int id,
        decimal amount,
        TransactionCategory category,
        DateTime date) : IRequest<Result<Transaction>>
    {
        public int Id { get; } = id;
        public decimal Amount { get; } = amount;
        public TransactionCategory Category { get; } = category;
        public DateTime Date { get; } = date;
    }
}
