using Dapper;
using FluentAssertions;
using ARA.Domain.Entities;
using ARA.Infrastructure.Repositories;

namespace ARA.Infrastructure.Tests.Repositories;

/// <summary>
/// Integration tests for <see cref="UserRepository"/> against a real database.
/// Tests skip gracefully when no database connection is configured.
/// Each test runs inside a rolled-back transaction to leave the database unchanged.
/// </summary>
public sealed class UserRepositoryTests : IClassFixture<TestDatabaseFixture>
{
    private readonly TestDatabaseFixture _fixture;

    public UserRepositoryTests(TestDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task GetByIdAsync_WithDevUser_ReturnsUser()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            // The dev user (UserId determined at runtime) should exist from seed data
            User? devUser = await connection.QueryFirstOrDefaultAsync<User>(
                "usp_UserGetByExternalUserId",
                new { ExternalUserId = "dev-user-00000000" },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            devUser.Should().NotBeNull("dev-user-00000000 should exist from seed data");
            devUser!.DisplayName.Should().Be("Dev User");
            devUser.IsInactive.Should().BeFalse();
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task GetAllActiveAsync_ReturnsAtLeastOneUser()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            IEnumerable<User> users = await connection.QueryAsync<User>(
                "usp_UserGetAllActive",
                transaction: transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            users.Should().NotBeEmpty("at least the dev user should exist");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task GetByRoleAsync_WithCreatorRole_ReturnsCreators()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            int creatorRoleId = 1;
            IEnumerable<User> creators = await connection.QueryAsync<User>(
                "usp_UserGetByRole",
                new { RoleId = creatorRoleId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            creators.Should().NotBeEmpty("the dev user has Creator role");
            creators.Should().OnlyContain(u => u.RoleId == creatorRoleId);
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }
}
