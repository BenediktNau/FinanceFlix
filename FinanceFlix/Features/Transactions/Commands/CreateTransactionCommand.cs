using Mediator;
using System.Transactions;

namespace FinanceFlix.Features.Transactions.Commands
{
    public class CreateTransactionCommand(Double amount, string description) : IRequest<Transaction> { };
    
}
