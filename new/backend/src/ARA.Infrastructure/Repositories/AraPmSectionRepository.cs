using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IAraPmSectionRepository"/>.
/// Maps to the <c>AraPmSection</c> table (legacy: <c>ara_PM</c>).
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class AraPmSectionRepository : IAraPmSectionRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="AraPmSectionRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public AraPmSectionRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<AraPmSection?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraPmSectionGetByAraId",
            parameters: new { AraId = araId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<AraPmSection>(cmd);
    }

    /// <inheritdoc/>
    public async Task UpsertAsync(AraPmSection section, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraPmSectionUpsert",
            parameters: new
            {
                section.AraId,
                section.FundsInAdvance,
                section.ContractDefinization,
                section.PertinentInformation,
                section.WorkStarted,
                section.Consequence,
                section.CurrentStatus,
                section.ChangeInScope,
                section.ActionToClear,
                section.EarlyStartNecessary,
                section.OtherNecessary,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
