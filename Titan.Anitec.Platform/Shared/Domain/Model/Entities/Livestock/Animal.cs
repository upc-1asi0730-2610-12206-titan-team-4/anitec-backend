namespace Anitec.Platform.Livestock.Domain.Model.Entities;

public class Animal
{
    public int Id { get; set; }
    public string Tag { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Species { get; set; } = string.Empty;
    public string Breed { get; set; } = string.Empty;
    public string Gender { get; set; } = string.Empty;
    public DateOnly? BirthDate { get; set; }
    public decimal Weight { get; set; }
    public string Status { get; set; } = string.Empty;
    public int HerdId { get; set; }
}
