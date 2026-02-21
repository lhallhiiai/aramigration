using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IDocumentRepository"/>.
/// Maps to the <c>AraAttachment</c> table (legacy: <c>attachments</c>).
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class DocumentRepository : IDocumentRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="DocumentRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public DocumentRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraDocument>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraAttachmentGetByAraId",
            parameters: new { AraId = araId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<AraDocument> results = await connection.QueryAsync<AraDocument>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<int> CreateAsync(AraDocument document, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraAttachmentCreate",
            parameters: new
            {
                AraId            = document.AraId,
                UploadedByUserId = document.UploadedByUserId,
                FileName         = document.FileName,
                StoragePath      = document.StoragePath,
            },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QuerySingleAsync<int>(cmd);
    }

    /// <inheritdoc/>
    public async Task DeleteAsync(int araDocumentId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_AraAttachmentDelete",
            parameters: new { AraAttachmentId = araDocumentId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        await connection.ExecuteAsync(cmd);
    }
}
