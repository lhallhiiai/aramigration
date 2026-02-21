using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IAraRepository"/>.
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class AraRepository : IAraRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="AraRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public AraRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<Ara?> GetByIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraGetById",
            parameters: new { AraId = araId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<Ara>(cmd);
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Ara>> GetPendingForUserAsync(int userId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraGetPendingForUser",
            parameters: new { UserId = userId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Ara> results = await connection.QueryAsync<Ara>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Ara>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraGetAllActive",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Ara> results = await connection.QueryAsync<Ara>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Ara>> GetByStatusAsync(AraStatus status, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraGetByStatus",
            parameters: new { StatusId = (int)status },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Ara> results = await connection.QueryAsync<Ara>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Ara>> GetArchivedAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraGetArchived",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Ara> results = await connection.QueryAsync<Ara>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Ara>> SearchByIdAsync(string searchTerm, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraSearchById",
            parameters: new { SearchTerm = searchTerm },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Ara> results = await connection.QueryAsync<Ara>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<Ara>> GetUpcomingExpirationsAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraGetUpcomingExpirations",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<Ara> results = await connection.QueryAsync<Ara>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<int> CreateAsync(Ara ara, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraCreate",
            parameters: new
            {
                ara.CategoryId,
                ara.StatusId,
                ara.CreatedByUserId,
                ara.ProgramManagerId,
                ara.ContractAdministratorId,
                ara.ControllerId,
                ara.OpsVpUserId,
                ara.Division,
                ara.ContractNumber,
                ara.DeliveryOrderNumber,
                ara.ContractType,
                ara.OmsNumber,
                ara.Title,
                ara.CustomerName,
                ara.AmountTotal,
                ara.AmountRequested,
                ara.TotalAnticipated,
                ara.PercentAnticipated,
                ara.RevenueDescriptionId,
                ara.IsEarlyStart,
                ara.EarlyStartReasonId,
                ara.EarlyStartReasonOther,
                ara.Company,
                ara.IsEac,
                ara.StartDate,
                ara.ExpirationDate,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QuerySingleAsync<int>(cmd);
    }

    /// <inheritdoc/>
    public async Task UpdateAsync(Ara ara, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraUpdate",
            parameters: new
            {
                ara.AraId,
                ara.CategoryId,
                ara.StatusId,
                ara.ProgramManagerId,
                ara.ContractAdministratorId,
                ara.ControllerId,
                ara.OpsVpUserId,
                ara.Reference,
                ara.JamisId,
                ara.Division,
                ara.ContractNumber,
                ara.DeliveryOrderNumber,
                ara.ContractType,
                ara.OmsNumber,
                ara.Title,
                ara.CustomerName,
                ara.AmountTotal,
                ara.AmountRequested,
                ara.TotalAnticipated,
                ara.PercentAnticipated,
                ara.RevenueDescriptionId,
                ara.IsEarlyStart,
                ara.EarlyStartReasonId,
                ara.EarlyStartReasonOther,
                ara.Company,
                ara.IsEac,
                ara.Revision,
                ara.StartDate,
                ara.ExpirationDate,
                ara.ExportedAt,
                ara.NegatedAt,
                ara.CancelledAt,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }

    /// <inheritdoc/>
    public async Task UpdateStatusAsync(
        int araId,
        AraStatus newStatus,
        int revision,
        DateTime? cancelledAt = null,
        DateTime? negatedAt = null,
        CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraUpdateStatus",
            parameters: new
            {
                AraId       = araId,
                StatusId    = (int)newStatus,
                Revision    = revision,
                CancelledAt = cancelledAt,
                NegatedAt   = negatedAt,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
