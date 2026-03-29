using FinanceFlix.Features.MailInboxes.Queries;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using FinanceFlix.Repositories.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Handlers
{
    public class GetMailInboxByIdHandler : IRequestHandler<GetMailInboxByIdQuery, Result<MailInbox>>
    {
        private readonly IMailInboxRepository _repository;

        public GetMailInboxByIdHandler(IMailInboxRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<MailInbox>> Handle(
            GetMailInboxByIdQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var inbox = await _repository.GetByIdAsync(request.InboxId, cancellationToken);
                return Result<MailInbox>.Success(inbox);
            }
            catch (Exception ex)
            {
                return Result<MailInbox>.Failure(ex.Message);
            }
        }
    }
}
