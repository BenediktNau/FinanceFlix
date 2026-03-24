using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Commands
{
    public class DeleteMailInboxCommand(int id) : IRequest<Result<bool>>
    {
        public int Id { get; } = id;
    }
}
