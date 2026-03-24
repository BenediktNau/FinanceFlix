namespace FinanceFlix.Models.MailInbox;

public class MailInbox
{
    public int Id { get; set; }
    public int AccountId { get; set; }
    public string DisplayName { get; set; }
    public string ImapHost { get; set; }
    public int ImapPort { get; set; }        // typically 993 (SSL)
    public bool UseSsl { get; set; }
    public string Username { get; set; }
    public string Password { get; set; }     // ⚠ plain text for now
    public string FolderName { get; set; }   // e.g. "Bills", "INBOX"
}