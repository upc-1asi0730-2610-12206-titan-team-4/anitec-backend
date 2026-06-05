namespace Anitec.Platform.Livestock.Domain.Model.Entities;

public class Herd
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string Owner { get; set; } = string.Empty;
    public int OwnerId { get; set; }
    public int? VeterinarianId { get; set; }
    public string MainType { get; set; } = string.Empty;
}
