namespace Anitec.Platform.Sanitary.Domain.Model.Entities;

public class HealthEvent
{
    public int Id { get; set; }
    public int AnimalId { get; set; }
    public string Type { get; set; } = string.Empty;
    public DateOnly Date { get; set; }
    public string Description { get; set; } = string.Empty;
    public string Veterinarian { get; set; } = string.Empty;
    public string Diagnosis { get; set; } = string.Empty;
    public string Treatment { get; set; } = string.Empty;
    public string Prescription { get; set; } = string.Empty;
    public string FollowUp { get; set; } = string.Empty;
    public DateOnly? NextDueDate { get; set; }
}
