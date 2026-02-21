using System.Data;

namespace ARA.Infrastructure.Database;

/// <summary>
/// Factory that produces open database connections ready for use with Dapper.
/// Callers are responsible for disposing the returned connection.
/// </summary>
public interface IDbConnectionFactory
{
    /// <summary>
    /// Creates and opens a new database connection.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the open operation.</param>
    /// <returns>An open <see cref="IDbConnection"/> that the caller must dispose.</returns>
    Task<IDbConnection> CreateAsync(CancellationToken cancellationToken = default);
}
