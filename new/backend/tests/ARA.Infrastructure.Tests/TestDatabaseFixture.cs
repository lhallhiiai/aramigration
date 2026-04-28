using System.Data;
using ARA.Infrastructure.Database;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace ARA.Infrastructure.Tests;

/// <summary>
/// Shared test fixture that provides a database connection factory for integration tests.
/// Connection string is read from the ARA_TEST_CONNECTION_STRING environment variable,
/// falling back to appsettings.Test.json. Tests skip gracefully when no connection
/// string is available.
/// </summary>
public sealed class TestDatabaseFixture : IAsyncLifetime
{
    private string _connectionString = string.Empty;

    /// <summary>Gets whether a valid database connection is available for testing.</summary>
    public bool IsAvailable { get; private set; }

    /// <summary>Creates a new open database connection for a test.</summary>
    public async Task<IDbConnection> CreateConnectionAsync(CancellationToken cancellationToken = default)
    {
        SqlConnection connection = new(_connectionString);
        await connection.OpenAsync(cancellationToken);
        return connection;
    }

    /// <summary>
    /// Creates a new open connection wrapped in a transaction.
    /// The caller should dispose the transaction (without committing) to roll back test data.
    /// </summary>
    public async Task<(IDbConnection Connection, IDbTransaction Transaction)> CreateTransactionalConnectionAsync(
        CancellationToken cancellationToken = default)
    {
        IDbConnection connection = await CreateConnectionAsync(cancellationToken);
        IDbTransaction transaction = connection.BeginTransaction();
        return (connection, transaction);
    }

    public async Task InitializeAsync()
    {
        IConfigurationRoot config = new ConfigurationBuilder()
            .AddJsonFile("appsettings.Test.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        _connectionString = Environment.GetEnvironmentVariable("ARA_TEST_CONNECTION_STRING")
            ?? config.GetConnectionString("AraDatabase")
            ?? string.Empty;

        if (string.IsNullOrWhiteSpace(_connectionString))
        {
            IsAvailable = false;
            return;
        }

        try
        {
            await using SqlConnection connection = new(_connectionString);
            await connection.OpenAsync();
            IsAvailable = true;
        }
        catch
        {
            IsAvailable = false;
        }
    }

    public Task DisposeAsync()
    {
        return Task.CompletedTask;
    }
}
