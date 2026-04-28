using Dapper;
using FluentAssertions;
using ARA.Domain.Entities;

namespace ARA.Infrastructure.Tests.Repositories;

/// <summary>
/// Integration tests for approval matrix stored procedures against a real database.
/// Verifies that usp_ApprovalMatrixGetActive and usp_ApprovalMatrixGetForAmount
/// return correctly shaped data matching <see cref="ApprovalMatrixEntry"/>.
/// </summary>
public sealed class ApprovalMatrixRepositoryTests : IClassFixture<TestDatabaseFixture>
{
    private readonly TestDatabaseFixture _fixture;

    private const int TotalMatrixEntries = 10;
    private const int RoutingEngineEntries = 7; // SequenceOrder 4-10
    private const int HighThresholdEntries = 3; // SequenceOrder 8-10 (>= $500K)
    private const decimal HighThresholdAmount = 500_000m;

    public ApprovalMatrixRepositoryTests(TestDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task GetActive_ReturnsAll10MatrixEntries()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            IEnumerable<ApprovalMatrixEntry> entries = await connection.QueryAsync<ApprovalMatrixEntry>(
                "usp_ApprovalMatrixGetActive",
                transaction: transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            List<ApprovalMatrixEntry> entryList = entries.ToList();
            entryList.Should().HaveCount(TotalMatrixEntries, "the approval matrix has exactly 10 roles");
            entryList.Should().BeInAscendingOrder(e => e.SequenceOrder);
            entryList.Should().OnlyContain(e => !e.IsInactive);
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task GetForAmount_Under500K_Returns4RoutingSteps()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            decimal amount = 100_000m;
            IEnumerable<ApprovalMatrixEntry> entries = await connection.QueryAsync<ApprovalMatrixEntry>(
                "usp_ApprovalMatrixGetForAmount",
                new { Amount = amount },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            List<ApprovalMatrixEntry> entryList = entries.ToList();
            int expectedCount = RoutingEngineEntries - HighThresholdEntries; // 4 steps
            entryList.Should().HaveCount(expectedCount, "ARAs under $500K skip steps 8-10");
            entryList.Should().OnlyContain(e => e.SequenceOrder >= 4 && e.SequenceOrder <= 7);
            entryList.Should().OnlyContain(e => e.MinimumAmount <= amount);
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task GetForAmount_AtOrAbove500K_ReturnsAll7RoutingSteps()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            IEnumerable<ApprovalMatrixEntry> entries = await connection.QueryAsync<ApprovalMatrixEntry>(
                "usp_ApprovalMatrixGetForAmount",
                new { Amount = HighThresholdAmount },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            List<ApprovalMatrixEntry> entryList = entries.ToList();
            entryList.Should().HaveCount(RoutingEngineEntries, "ARAs >= $500K use all 7 routing steps");
            entryList.Should().BeInAscendingOrder(e => e.SequenceOrder);
            entryList.Min(e => e.SequenceOrder).Should().Be(4, "routing starts at step 4");
            entryList.Max(e => e.SequenceOrder).Should().Be(10, "MTC COO is step 10");
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }

    [Fact]
    public async Task GetForAmount_AllEntriesHaveRequiredFields()
    {
        if (!_fixture.IsAvailable) return;

        (System.Data.IDbConnection connection, System.Data.IDbTransaction transaction) =
            await _fixture.CreateTransactionalConnectionAsync();

        try
        {
            IEnumerable<ApprovalMatrixEntry> entries = await connection.QueryAsync<ApprovalMatrixEntry>(
                "usp_ApprovalMatrixGetForAmount",
                new { Amount = HighThresholdAmount },
                transaction,
                commandType: System.Data.CommandType.StoredProcedure);

            foreach (ApprovalMatrixEntry entry in entries)
            {
                entry.RoleName.Should().NotBeNullOrWhiteSpace("every matrix entry must have a role name");
                entry.JobTitleId.Should().BeGreaterThan(0, "every entry must reference a valid job title");
                entry.IsDelegable.Should().BeTrue("all 10 roles in the matrix are delegable per user guide");
            }
        }
        finally
        {
            transaction.Rollback();
            connection.Dispose();
        }
    }
}
