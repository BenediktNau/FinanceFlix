using FinanceFlix.Features.MailInboxes.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using FinanceFlix.Repositories.MailInbox;
using FinanceFlix.Services.Mail;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Handlers
{
    public class CreateMailInboxHandler : IRequestHandler<CreateMailInboxCommand, Result<MailInbox>>
    {
        private readonly IMailInboxRepository _repository;
        private readonly ILogger<CreateMailInboxHandler> _logger;
        private readonly MailListenerService _mailListenerService;

        public CreateMailInboxHandler(IMailInboxRepository repository, ILogger<CreateMailInboxHandler> logger, MailListenerService mailListenerService)
        {
            _repository = repository;
            _logger = logger;
            _mailListenerService = mailListenerService;
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
                _logger.LogInformation("Created mailInbox entry ({id}) for {Account}", inbox.Id, inbox.AccountId);

                _mailListenerService.StartOnAdding(created.Id);

                return Result<MailInbox>.Success(created);
            }
            catch (Exception ex)
            {
                return Result<MailInbox>.Failure(ex.Message);
            }
        }
    }
}
