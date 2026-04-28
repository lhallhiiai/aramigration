using System.Data;
using ARA.Infrastructure.Database;
using Dapper;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace ARA.Infrastructure.HealthChecks;

/// <summary>
/// Readiness probe for the ARA Azure SQL database. Opens a connection through
/// <see cref="IDbConnectionFactory"/> and runs <c>SELECT 1</c>; succeeds when
/// the round-trip completes within the host's check timeout.
/// </summary>
public sealed class SqlConnectivityHealthCheck : IHealthCheck
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="SqlConnectivityHealthCheck"/>.</summary>
    public SqlConnectivityHealthCheck(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
            int probe = await connection.ExecuteScalarAsync<int>(
                new CommandDefinition("SELECT 1", cancellationToken: cancellationToken));
            return probe == 1
                ? HealthCheckResult.Healthy("AraDatabase reachable.")
                : HealthCheckResult.Unhealthy($"AraDatabase probe returned unexpected value '{probe}'.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("AraDatabase unreachable.", ex);
        }
    }
}
