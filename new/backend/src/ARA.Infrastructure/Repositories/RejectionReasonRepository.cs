using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IRejectionReasonRepository"/>.
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class RejectionReasonRepository : IRejectionReasonRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="RejectionReasonRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public RejectionReasonRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<RejectionReason>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_RejectionReasonGetAllActive",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<RejectionReason> results = await connection.QueryAsync<RejectionReason>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<RejectionReason?> GetByIdAsync(int rejectionReasonId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_RejectionReasonGetById",
            parameters: new { RejectionReasonId = rejectionReasonId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<RejectionReason>(cmd);
    }
}
