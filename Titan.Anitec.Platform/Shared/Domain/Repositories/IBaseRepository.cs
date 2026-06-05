namespace Anitec.Platform.Shared.Domain.Repositories;

/// <summary>
///     Base repository interface for all repositories
/// </summary>
/// <remarks>
///     This interface is used to define the basic CRUD operations for all repositories
/// </remarks>
/// <typeparam name="TEntity">
///     The entity type for the repository
/// </typeparam>

    void Update(TEntity entity);

    /// <summary>
    ///     Remove an entity from the repository
    /// </summary>
    /// <param name="entity">
    ///     The entity to remove
    /// </param>
    void Remove(TEntity entity);

    /// <summary>
    ///     List all entities in the repository
    /// </summary>
    /// <param name="cancellationToken">The cancellation token</param>
    /// <returns>
    ///     A list of all entities in the repository
    /// </returns>
    Task<IEnumerable<TEntity>> ListAsync(CancellationToken cancellationToken = default);
}
