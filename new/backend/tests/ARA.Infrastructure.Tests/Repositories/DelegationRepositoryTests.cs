using Dapper;
using FluentAssertions;
using ARA.Domain.Entities;

namespace ARA.Infrastructure.Tests.Repositories;

/// <summary>
/// Integration tests for delegation stored procedures against a real database.
/// Each test runs inside a rolled-back transaction to leave the database unchanged.
/// </summary>
public sealed class DelegationRepositoryTests : IClassFixture<TestDatabaseFixture>
{
    private readonly TestDatabaseFixture _fixture;

    public DelegationRepositoryTests(TestDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task CreateAndGetActive_NewDelegation_IsRetrievable()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            // Create a delegation from dev user (ID 1) to a hypothetical user (ID 2)
            // First verify dev user exists
            User? devUser = await connection.QueryFirstOrDefaultAsync<User>(
                "usp_UserGetByExternalUserId",
                new { ExternalUserId = "dev-user-00000000" },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            if (devUser is null) return;

            int delegationId = await connection.QuerySingleAsync<int>(
                "usp_DelegationCreate",
                new
                {
                    DelegatorUserId = devUser!.UserId,
                    DelegateeUserId = devUser.UserId + 1000, // Safe non-existent ID within transaction
                    StartDate = DateTime.UtcNow.AddDays(-1),
                    EndDate = DateTime.UtcNow.AddDays(30)
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            delegationId.Should().BeGreaterThan(0);

            // Retrieve it
            Delegation? delegation = await connection.QueryFirstOrDefaultAsync<Delegation>(
                "usp_DelegationGetActiveForUser",
                new { DelegatorUserId = devUser.UserId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            delegation.Should().NotBeNull();
            delegation!.DelegationId.Should().Be(delegationId);
            delegation.DelegatorUserId.Should().Be(devUser.UserId);
            delegation.IsActive.Should().BeTrue();
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task Deactivate_ExistingDelegation_NoLongerActive()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            User? devUser = await connection.QueryFirstOrDefaultAsync<User>(
                "usp_UserGetByExternalUserId",
                new { ExternalUserId = "dev-user-00000000" },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            if (devUser is null) return;

            int delegationId = await connection.QuerySingleAsync<int>(
                "usp_DelegationCreate",
                new
                {
                    DelegatorUserId = devUser!.UserId,
                    DelegateeUserId = devUser.UserId + 1000,
                    StartDate = DateTime.UtcNow.AddDays(-1),
                    EndDate = DateTime.UtcNow.AddDays(30)
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            // Deactivate
            await connection.ExecuteAsync(
                "usp_DelegationDeactivate",
                new { DelegationId = delegationId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            // Should no longer appear as active
            Delegation? delegation = await connection.QueryFirstOrDefaultAsync<Delegation>(
                "usp_DelegationGetActiveForUser",
                new { DelegatorUserId = devUser.UserId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            delegation.Should().BeNull("deactivated delegation should not appear in active queries");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task GetAllActive_ReturnsOnlyCurrentDelegations()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            // Query with no delegation data should return empty or only pre-existing ones
            IEnumerable<Delegation> delegations = await connection.QueryAsync<Delegation>(
                "usp_DelegationGetAllActive",
                transaction: transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            delegations.Should().OnlyContain(d => d.IsActive, "all returned delegations should be active");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }
}
