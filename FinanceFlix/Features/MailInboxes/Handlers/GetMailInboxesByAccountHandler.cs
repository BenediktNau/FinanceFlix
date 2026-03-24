using FinanceFlix.Features.MailInboxes.Queries;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using FinanceFlix.Repositories.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Handlers
{
    public class GetMailInboxesByAccountHandler : IRequestHandler<GetMailInboxesByAccountQuery, Result<List<MailInbox>>>
    {
        private readonly IMailInboxRepository _repository;

        public GetMailInboxesByAccountHandler(IMailInboxRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<List<MailInbox>>> Handle(
            GetMailInboxesByAccountQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var inboxes = await _repository.GetByAccountIdAsync(request.AccountId, cancellationToken);
                return Result<List<MailInbox>>.Success(inboxes);
            }
            catch (Exception ex)
            {
                return Result<List<MailInbox>>.Failure(ex.Message);
            }
        }
    }
}
