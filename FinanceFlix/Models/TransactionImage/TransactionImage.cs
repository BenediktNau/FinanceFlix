namespace FinanceFlix.Models.TransactionImage;

public class TransactionImage
{
    public int Id { get; set; }
    public int TransactionId { get; set; }
    public string FilePath { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
}
