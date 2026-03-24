using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Commands
{
    public class CreateMailInboxCommand(
        int accountId,
        string displayName,
        string imapHost,
        int imapPort,
        bool useSsl,
        string username,
        string password,
        string folderName) : IRequest<Result<MailInbox>>
    {
        public int AccountId { get; } = accountId;
        public string DisplayName { get; } = displayName;
        public string ImapHost { get; } = imapHost;
        public int ImapPort { get; } = imapPort;
        public bool UseSsl { get; } = useSsl;
        public string Username { get; } = username;
        public string Password { get; } = password;
        public string FolderName { get; } = folderName;
    }
}
