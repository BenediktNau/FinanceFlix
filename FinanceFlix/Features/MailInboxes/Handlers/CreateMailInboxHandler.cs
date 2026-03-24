using FinanceFlix.Features.MailInboxes.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using FinanceFlix.Repositories.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Handlers
{
    public class CreateMailInboxHandler : IRequestHandler<CreateMailInboxCommand, Result<MailInbox>>
    {
        private readonly IMailInboxRepository _repository;

        public CreateMailInboxHandler(IMailInboxRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<MailInbox>> Handle(
            CreateMailInboxCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var inbox = new MailInbox
                {
                    AccountId = request.AccountId,
                    DisplayName = request.DisplayName,
                    ImapHost = request.ImapHost,
                    ImapPort = request.ImapPort,
                    UseSsl = request.UseSsl,
                    Username = request.Username,
                    Password = request.Password,
                    FolderName = request.FolderName
                };
                var created = await _repository.AddAsync(inbox, cancellationToken);
                return Result<MailInbox>.Success(created);
            }
            catch (Exception ex)
            {
                return Result<MailInbox>.Failure(ex.Message);
            }
        }
    }
}
