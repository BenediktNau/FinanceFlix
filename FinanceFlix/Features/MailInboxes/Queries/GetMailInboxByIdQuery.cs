using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Queries
{
    public class GetMailInboxByIdQuery(int inboxId) : IRequest<Result<MailInbox>>
    {
        public int InboxId { get; } = inboxId;
    }
}
