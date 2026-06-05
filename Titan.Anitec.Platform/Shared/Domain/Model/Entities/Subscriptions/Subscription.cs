namespace Anitec.Platform.Subscriptions.Domain.Model.Entities;

public class Subscription
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int PlanId { get; set; }
    public string StripeCustomerId { get; set; } = string.Empty;
    public string StripeSubscriptionId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateOnly StartedAt { get; set; }
    public DateOnly? EndsAt { get; set; }
}
