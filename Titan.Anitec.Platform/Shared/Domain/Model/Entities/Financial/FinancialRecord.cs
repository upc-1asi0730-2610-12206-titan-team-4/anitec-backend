namespace Anitec.Platform.Financial.Domain.Model.Entities;

public class FinancialRecord
{
    public int Id { get; set; }
    public int OwnerId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateOnly Date { get; set; }
    public string Description { get; set; } = string.Empty;
}
