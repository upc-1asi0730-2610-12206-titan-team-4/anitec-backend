using Anitec.Platform.Profiles.Domain.Model.ValueObjects;
using Anitec.Platform.Shared.Domain.Model.Entities;

namespace Anitec.Platform.Profiles.Domain.Model.Aggregates;

public class Profile : IAuditableEntity
{
    public int Id { get; set; }
    public PersonName Name { get; set; } = null!;
    public EmailAddress Email { get; set; } = null!;
    public StreetAddress Address { get; set; } = null!;
    public DateTimeOffset? CreatedAt { get; set; }
    public DateTimeOffset? UpdatedAt { get; set; }
}
