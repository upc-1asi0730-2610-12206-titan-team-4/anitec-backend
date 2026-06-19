using Anitec.Platform.Profiles.Domain.Model.Aggregates;
using Anitec.Platform.Profiles.Domain.Model.ValueObjects;
using Anitec.Platform.Shared.Domain.Repositories;

namespace Anitec.Platform.Profiles.Domain.Repositories;

/// <summary>
///     Profile repository interface
/// </summary>
public interface IProfileRepository : IBaseRepository<Profile>
{
    
    Task<Profile?> FindProfileByEmailAsync(EmailAddress email, CancellationToken cancellationToken);
}
