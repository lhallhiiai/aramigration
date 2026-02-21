using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace ARA.Infrastructure.Database;

/// <summary>
/// Opens Azure SQL connections using the <c>AraDatabase</c> connection string.
/// In development the connection string uses <c>Authentication=Active Directory Default</c>,
/// which resolves to the developer's <c>az login</c> session.
/// In Azure the same setting resolves to the Container App's Managed Identity.
/// </summary>
public sealed class SqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    /// <summary>Initializes the factory, resolving the connection string from configuration.</summary>
    /// <param name="configuration">Application configuration that must contain the <c>AraDatabase</c> connection string.</param>
    /// <exception cref="InvalidOperationException">Thrown when the connection string is absent or empty.</exception>
    public SqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("AraDatabase")
            ?? throw new InvalidOperationException(
                "Connection string 'AraDatabase' is not configured. " +
                "Add it to appsettings.json or appsettings.Development.json.");
    }

    /// <inheritdoc/>
    public async Task<IDbConnection> CreateAsync(CancellationToken cancellationToken = default)
    {
        SqlConnection connection = new(_connectionString);
        await connection.OpenAsync(cancellationToken);
        return connection;
    }
}
