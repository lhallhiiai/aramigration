using ARA.Application.Common;
using ARA.Application.Users;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Users;

/// <summary>
/// Tests for <see cref="UserService"/> covering role-based retrieval and active user listing.
/// </summary>
public sealed class UserServiceTests
{
    private readonly Mock<IUserRepository> _userRepo = new();
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _sut = new UserService(
            _userRepo.Object,
            Mock.Of<ILogger<UserService>>());
    }

    [Fact]
    public async Task GetByRoleAsync_WithMatchingUsers_ReturnsFilteredList()
    {
        List<User> users =
        [
            new()
            {
                UserId = 1, DisplayName = "Alice Smith", FirstName = "Alice", LastName = "Smith",
                Email = "alice@test.com", RoleId = (int)UserRole.ContractAdministrator, JobTitleId = 2,
                IsInactive = false, ExternalUserId = "ext-1",
            },
            new()
            {
                UserId = 2, DisplayName = "Bob Jones", FirstName = "Bob", LastName = "Jones",
                Email = "bob@test.com", RoleId = (int)UserRole.ContractAdministrator, JobTitleId = 2,
                IsInactive = false, ExternalUserId = "ext-2",
            },
        ];
        _userRepo.Setup(r => r.GetByRoleAsync(UserRole.ContractAdministrator, It.IsAny<CancellationToken>()))
            .ReturnsAsync(users.AsReadOnly());

        IReadOnlyList<UserDto> result = await _sut.GetByRoleAsync(UserRole.ContractAdministrator, CancellationToken.None);

        result.Should().HaveCount(2);
        result[0].UserId.Should().Be(1);
        result[0].DisplayName.Should().Be("Alice Smith");
        result[0].Role.Should().Be(UserRole.ContractAdministrator);
        result[1].UserId.Should().Be(2);
    }

    [Fact]
    public async Task GetAllActiveAsync_WithActiveUsers_ReturnsMappedDtos()
    {
        List<User> users =
        [
            new()
            {
                UserId = 10, DisplayName = "Charlie Brown", FirstName = "Charlie", LastName = "Brown",
                Email = "charlie@test.com", RoleId = (int)UserRole.Creator, JobTitleId = 4,
                IsInactive = false, ExternalUserId = "ext-10",
            },
        ];
        _userRepo.Setup(r => r.GetAllActiveAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(users.AsReadOnly());

        IReadOnlyList<UserDto> result = await _sut.GetAllActiveAsync(CancellationToken.None);

        result.Should().HaveCount(1);
        result[0].UserId.Should().Be(10);
        result[0].DisplayName.Should().Be("Charlie Brown");
        result[0].FirstName.Should().Be("Charlie");
        result[0].LastName.Should().Be("Brown");
        result[0].Email.Should().Be("charlie@test.com");
        result[0].Role.Should().Be(UserRole.Creator);
        result[0].JobTitleId.Should().Be(4);
    }

    [Fact]
    public async Task GetByRoleAsync_WithNoMatchingUsers_ReturnsEmptyList()
    {
        _userRepo.Setup(r => r.GetByRoleAsync(UserRole.Approver, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<User>().AsReadOnly());

        IReadOnlyList<UserDto> result = await _sut.GetByRoleAsync(UserRole.Approver, CancellationToken.None);

        result.Should().BeEmpty();
    }
}
