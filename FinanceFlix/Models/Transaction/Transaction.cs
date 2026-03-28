using System.Text.Json.Serialization;
using FinanceFlix.Models.TransactionImage;

namespace FinanceFlix.Models.Transaction;

public class Transaction
{
    public int Id { get; set; }
    public int AccountId { get; set; }
    public decimal Amount { get; set; }
    public string? Description { get; set; }
    public TransactionCategory Category { get; set; }
    public DateTime Date { get; set; }
    [JsonIgnore]
    public List<TransactionImage.TransactionImage> Images { get; set; } = [];
    public int ImageCount => Images.Count;
}