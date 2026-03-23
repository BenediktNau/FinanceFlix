namespace FinanceFlix.Models.Account;

public class Account
{
    public int AccountId { get; set; }
    public string UserId { get; set; }
    public string AccountName { get; set; }
    public Decimal Balance { get; set; }
}