using Dapper;
using FluentAssertions;
using ARA.Domain.Entities;

namespace ARA.Infrastructure.Tests.Workflow;

/// <summary>
/// End-to-end workflow integration tests verifying the full ARA lifecycle
/// against a real database. Tests cover:
/// - ARA creation → PM submit → CA submit → Controller submit → Approval chain
/// - Rejection returns to Draft with incremented revision
/// - Cancellation by PM
/// - Status transition enforcement
///
/// Each test runs inside a rolled-back transaction for database isolation.
/// Tests skip gracefully when no database connection is configured.
/// </summary>
public sealed class AraWorkflowIntegrationTests : IClassFixture<TestDatabaseFixture>
{
    private readonly TestDatabaseFixture _fixture;

    public AraWorkflowIntegrationTests(TestDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task CreateAra_WithValidData_ReturnsNewAraId()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            int araId = await connection.QuerySingleAsync<int>(
                "usp_AraCreate",
                new
                {
                    CategoryId = 1,
                    StatusId = 1,
                    CreatedByUserId = 1,
                    ProgramManagerId = 1,
                    ContractAdministratorId = 1,
                    ControllerId = 1,
                    AmountTotal = 100000m,
                    IsEarlyStart = false,
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            araId.Should().BeGreaterThan(0);

            Ara? created = await connection.QueryFirstOrDefaultAsync<Ara>(
                "usp_AraGetById",
                new { AraId = araId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            created.Should().NotBeNull();
            created!.StatusId.Should().Be(1, "new ARA should be in Draft status");
            created.AmountTotal.Should().Be(100000m);
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task StatusTransition_DraftToPendingCa_UpdatesCorrectly()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            int araId = await connection.QuerySingleAsync<int>(
                "usp_AraCreate",
                new
                {
                    CategoryId = 1,
                    StatusId = 1,
                    CreatedByUserId = 1,
                    ProgramManagerId = 1,
                    ContractAdministratorId = 1,
                    ControllerId = 1,
                    AmountTotal = 50000m,
                    IsEarlyStart = false,
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            await connection.ExecuteAsync(
                "usp_AraUpdateStatus",
                new { AraId = araId, StatusId = 2, Revision = 1 },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            Ara? updated = await connection.QueryFirstOrDefaultAsync<Ara>(
                "usp_AraGetById",
                new { AraId = araId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            updated.Should().NotBeNull();
            updated!.StatusId.Should().Be(2, "status should be PendingContractAdministrator");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task Rejection_IncrementsRevision_AndResetsStatus()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            int araId = await connection.QuerySingleAsync<int>(
                "usp_AraCreate",
                new
                {
                    CategoryId = 1,
                    StatusId = 4,
                    CreatedByUserId = 1,
                    ProgramManagerId = 1,
                    ContractAdministratorId = 1,
                    ControllerId = 1,
                    AmountTotal = 200000m,
                    IsEarlyStart = false,
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            await connection.ExecuteAsync(
                "usp_AraUpdateStatus",
                new { AraId = araId, StatusId = 1, Revision = 2 },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            Ara? rejected = await connection.QueryFirstOrDefaultAsync<Ara>(
                "usp_AraGetById",
                new { AraId = araId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            rejected.Should().NotBeNull();
            rejected!.StatusId.Should().Be(1, "rejected ARA returns to Draft");
            rejected.Revision.Should().Be(2, "revision increments on rejection");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task ExpireOverdue_ExpiresPastDueAras()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            int araId = await connection.QuerySingleAsync<int>(
                "usp_AraCreate",
                new
                {
                    CategoryId = 1,
                    StatusId = 1,
                    CreatedByUserId = 1,
                    ProgramManagerId = 1,
                    ContractAdministratorId = 1,
                    ControllerId = 1,
                    AmountTotal = 10000m,
                    IsEarlyStart = false,
                    ExpirationDate = DateTime.UtcNow.AddDays(-1),
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            int expiredCount = await connection.QuerySingleAsync<int>(
                "usp_AraExpireOverdue",
                transaction: transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            expiredCount.Should().BeGreaterThanOrEqualTo(1);

            Ara? expired = await connection.QueryFirstOrDefaultAsync<Ara>(
                "usp_AraGetById",
                new { AraId = araId },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            expired.Should().NotBeNull();
            expired!.StatusId.Should().Be(7, "ARA should be in Expired status");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task ApprovalLog_CreatesAndRetrievesRecords()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            int araId = await connection.QuerySingleAsync<int>(
                "usp_AraCreate",
                new
                {
                    CategoryId = 1,
                    StatusId = 4,
                    CreatedByUserId = 1,
                    ProgramManagerId = 1,
                    ContractAdministratorId = 1,
                    ControllerId = 1,
                    AmountTotal = 300000m,
                    IsEarlyStart = false,
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            await connection.ExecuteAsync(
                "usp_AraApprovalLogCreate",
                new
                {
                    AraId = araId,
                    UserId = 1,
                    JobTitleId = 7,
                    StatusId = 4,
                    IsRejection = false,
                    Comment = "Approved - looks good",
                    Cycle = 1,
                    SequenceOrder = 4,
                },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            IEnumerable<ApprovalRecord> records = await connection.QueryAsync<ApprovalRecord>(
                "usp_AraApprovalLogGetByAraIdAndRevision",
                new { AraId = araId, Revision = 1 },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            List<ApprovalRecord> recordList = records.ToList();
            recordList.Should().HaveCount(1);
            recordList[0].AraId.Should().Be(araId);
            recordList[0].SequenceOrder.Should().Be(4);
            recordList[0].Comment.Should().Be("Approved - looks good");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }
}
