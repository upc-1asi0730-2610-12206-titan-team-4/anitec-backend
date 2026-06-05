namespace Anitec.Platform.Metrics.Domain.Model.Entities;

public class DeviceMetric
{
    public int Id { get; set; }
    public int DeviceId { get; set; }
    public string Type { get; set; } = string.Empty;
    public decimal Value { get; set; }
    public string Unit { get; set; } = string.Empty;
    public DateTime RecordedAt { get; set; }
}
