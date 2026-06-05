namespace Anitec.Platform.Activities.Domain.Model.Entities;

public class FarmActivity
{
    public int Id { get; set; }
    public int? OwnerId { get; set; }
    public int? VeterinarianId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public DateOnly Date { get; set; }
    public string Priority { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}
