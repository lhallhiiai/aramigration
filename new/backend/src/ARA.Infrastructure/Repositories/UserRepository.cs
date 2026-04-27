using System.Data;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using Dapper;

namespace ARA.Infrastructure.Repositories;

/// <summary>
/// Dapper-based implementation of <see cref="IUserRepository"/>.
/// All data access is performed via parameterized stored procedures.
/// </summary>
public sealed class UserRepository : IUserRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    /// <summary>Initializes a new instance of <see cref="UserRepository"/>.</summary>
    /// <param name="connectionFactory">Factory used to create database connections.</param>
    public UserRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc/>
    public async Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_UserGetById",
            parameters: new { UserId = userId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<User>(cmd);
    }

    /// <inheritdoc/>
    public async Task<User?> GetByExternalUserIdAsync(string externalUserId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_UserGetByExternalUserId",
            parameters: new { ExternalUserId = externalUserId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        return await connection.QueryFirstOrDefaultAsync<User>(cmd);
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<User>> GetByRoleAsync(UserRole role, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_UserGetByRole",
            parameters: new { RoleId = (int)role },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<User> results = await connection.QueryAsync<User>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<User>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_UserGetAllActive",
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<User> results = await connection.QueryAsync<User>(cmd);
        return results.ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<User>> GetByJobTitleIdAsync(int jobTitleId, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);
        CommandDefinition cmd = new(
            commandText: "usp_UserGetByJobTitleId",
            parameters: new { JobTitleId = jobTitleId },
            commandType: CommandType.StoredProcedure,
            cancellationToken: cancellationToken);
        IEnumerable<User> results = await connection.QueryAsync<User>(cmd);
        return results.ToList().AsReadOnly();
    }
}
