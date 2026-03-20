using FinanceFlix.Models.Transaction;
using Mediator;

namespace FinanceFlix.Features.Transactions.Commands
{
    public class CreateTransactionCommand(
        double amount,
        string description,
        TransactionCategory category) : IRequest<Transaction> { }
}
