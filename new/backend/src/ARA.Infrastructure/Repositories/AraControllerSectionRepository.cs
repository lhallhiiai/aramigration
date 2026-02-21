using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IAraControllerSectionRepository"/>.
/// Maps to the <c>AraControllerSection</c> table (legacy: <c>ara_con</c>).
/// TotalCost and TotalFee are recalculated by the upsert stored procedure from current CLIN entries.
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class AraControllerSectionRepository : IAraControllerSectionRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="AraControllerSectionRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public AraControllerSectionRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<AraControllerSection?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraControllerSectionGetByAraId",
            parameters: new { AraId = araId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<AraControllerSection>(cmd);
    }

    /// <inheritdoc/>
    public async Task UpsertAsync(AraControllerSection section, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraControllerSectionUpsert",
            parameters: new
            {
                section.AraId,
                section.ControllerId,
                section.InterestImpact,
                section.BurnRate,
                section.IncurredCost,
                section.IncurredFee,
                section.Company,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
