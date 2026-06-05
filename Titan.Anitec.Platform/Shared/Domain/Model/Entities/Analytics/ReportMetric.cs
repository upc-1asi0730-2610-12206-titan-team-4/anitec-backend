namespace Anitec.Platform.Analytics.Domain.Model.Entities;

public class ReportMetric
{
    public int Id { get; set; }
    public string Label { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string Trend { get; set; } = string.Empty;
}
