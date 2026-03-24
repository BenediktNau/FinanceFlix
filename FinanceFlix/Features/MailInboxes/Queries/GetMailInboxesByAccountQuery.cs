using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Queries
{
    public class GetMailInboxesByAccountQuery(int accountId) : IRequest<Result<List<MailInbox>>>
    {
        public int AccountId { get; } = accountId;
    }
}
