using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Transactions.Commands
{
    public class DeleteTransactionCommand(int id) : IRequest<Result<bool>>
    {
        public int Id { get; } = id;
    }
}
