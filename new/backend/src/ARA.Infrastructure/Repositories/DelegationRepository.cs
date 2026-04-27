using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IDelegationRepository"/>.
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class DelegationRepository : IDelegationRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="DelegationRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public DelegationRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<Delegation?> GetActiveDelegationForUserAsync(int delegatorUserId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_DelegationGetActiveForUser",
            parameters: new { DelegatorUserId = delegatorUserId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<Delegation>(cmd);
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Delegation>> GetActiveDelegationsForDelegateeAsync(int delegateeUserId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_DelegationGetActiveForDelegatee",
            parameters: new { DelegateeUserId = delegateeUserId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Delegation> results = await connection.QueryAsync<Delegation>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Delegation>> GetActiveDelegationsAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_DelegationGetAllActive",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Delegation> results = await connection.QueryAsync<Delegation>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<int> CreateAsync(Delegation delegation, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_DelegationCreate",
            parameters: new
            {
                delegation.DelegatorUserId,
                delegation.DelegateeUserId,
                delegation.StartDate,
                delegation.EndDate,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QuerySingleAsync<int>(cmd);
    }

    /// <inheritdoc/>
    public async Task DeactivateAsync(int delegationId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_DelegationDeactivate",
            parameters: new { DelegationId = delegationId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
