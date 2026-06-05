using Anitec.Platform.Shared.Domain.Model.Entities;

namespace Anitec.Platform.Iam.Domain.Model.Aggregates;

public class User : IAuditableEntity
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public DateTimeOffset? CreatedAt { get; set; }
    public DateTimeOffset? UpdatedAt { get; set; }
}
