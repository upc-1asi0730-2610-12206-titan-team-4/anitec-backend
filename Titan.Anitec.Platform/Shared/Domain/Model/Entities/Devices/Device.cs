namespace Anitec.Platform.Devices.Domain.Model.Entities;

public class Device
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public string SerialNumber { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int? HerdId { get; set; }
    public int? AnimalId { get; set; }
}
