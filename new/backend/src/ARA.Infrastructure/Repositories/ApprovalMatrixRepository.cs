using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IApprovalMatrixRepository"/>.
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class ApprovalMatrixRepository : IApprovalMatrixRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="ApprovalMatrixRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public ApprovalMatrixRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ApprovalMatrixEntry>> GetActiveEntriesAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_ApprovalMatrixGetActive",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<ApprovalMatrixEntry> results = await connection.QueryAsync<ApprovalMatrixEntry>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ApprovalMatrixEntry>> GetRequiredEntriesForAmountAsync(decimal amount, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_ApprovalMatrixGetForAmount",
            parameters: new { Amount = amount },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<ApprovalMatrixEntry> results = await connection.QueryAsync<ApprovalMatrixEntry>(cmd);
        return results.ToList().AsReadOnly();
    }
}
