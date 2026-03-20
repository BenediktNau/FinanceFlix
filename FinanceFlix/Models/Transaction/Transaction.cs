namespace FinanceFlix.Models.Transaction;

public class Transaction
{
    public int Id { get; set; }
    public int AccountId { get; set; }
    public decimal Amount { get; set; }
    public TransactionCategory Category { get; set; }
    public DateTime Date { get; set; }
}