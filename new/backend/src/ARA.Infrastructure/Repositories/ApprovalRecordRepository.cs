using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IApprovalRecordRepository"/>.
/// All data access is performed via parameterized stored procedures.
/// The approval log is append-only; records are never updated or deleted.
/// </summary>
public sealed class ApprovalRecordRepository : IApprovalRecordRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="ApprovalRecordRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public ApprovalRecordRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ApprovalRecord>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraApprovalLogGetByAraId",
            parameters: new { AraId = araId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<ApprovalRecord> results = await connection.QueryAsync<ApprovalRecord>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ApprovalRecord>> GetByAraIdAndRevisionAsync(
        int araId, int revision, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraApprovalLogGetByAraIdAndRevision",
            parameters: new { AraId = araId, Revision = revision },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<ApprovalRecord> results = await connection.QueryAsync<ApprovalRecord>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task CreateAsync(ApprovalRecord record, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraApprovalLogCreate",
            parameters: new
            {
                AraId             = record.AraId,
                UserId            = record.ApproverId,
                JobTitleId        = record.JobTitleId,
                IsRejection       = record.Action == ApprovalActionType.Reject,
                Comment           = record.Comment,
                Cycle             = record.AraRevision,
                RejectionReasonId = record.RejectionReasonId,
                RejectionAreas    = record.RejectionAreas,
                SequenceOrder     = record.SequenceOrder,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
