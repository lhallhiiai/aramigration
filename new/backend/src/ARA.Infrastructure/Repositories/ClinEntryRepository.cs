using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IClinEntryRepository"/>.
/// Maps to the <c>Clin</c> table (legacy: <c>clins</c>).
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class ClinEntryRepository : IClinEntryRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="ClinEntryRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public ClinEntryRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ClinEntry>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_ClinGetByAraId",
            parameters: new { AraId = araId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<ClinEntry> results = await connection.QueryAsync<ClinEntry>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<int> CreateAsync(ClinEntry entry, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_ClinCreate",
            parameters: new
            {
                AraId       = entry.AraId,
                ClinNumber  = entry.ClinNumber,
                Description = entry.ClinDescription,
                CostFunding = entry.Cost,
                FeeFunding  = entry.Fee,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QuerySingleAsync<int>(cmd);
    }

    /// <inheritdoc/>
    public async Task UpdateAsync(ClinEntry entry, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_ClinUpdate",
            parameters: new
            {
                ClinId      = entry.ClinEntryId,
                ClinNumber  = entry.ClinNumber,
                Description = entry.ClinDescription,
                CostFunding = entry.Cost,
                FeeFunding  = entry.Fee,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }

    /// <inheritdoc/>
    public async Task DeleteAsync(int clinEntryId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_ClinDelete",
            parameters: new { ClinId = clinEntryId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
