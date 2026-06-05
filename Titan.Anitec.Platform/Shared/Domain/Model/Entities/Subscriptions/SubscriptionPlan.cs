namespace Anitec.Platform.Subscriptions.Domain.Model.Entities;

public class SubscriptionPlan
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string StripePriceId { get; set; } = string.Empty;
    public int MaxAnimals { get; set; }
    public bool IsActive { get; set; }
}
