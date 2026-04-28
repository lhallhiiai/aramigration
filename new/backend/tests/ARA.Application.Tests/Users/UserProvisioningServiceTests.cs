using System.Security.Claims;
using ARA.Application.Common;
using ARA.Application.Users;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Users;

/// <summary>Unit tests for <see cref="UserProvisioningService"/> (Item 4).</summary>
public sealed class UserProvisioningServiceTests
{
    private const string Sub = "00uxxxxxxxxxxxxxx";
    private const string Email = "person@example.com";

    private readonly Mock<IUserRepository> _userRepo;
    private readonly Mock<ILogger<UserProvisioningService>> _logger;
    private readonly UserProvisioningService _sut;

    public UserProvisioningServiceTests()
    {
        _userRepo = new Mock<IUserRepository>();
        _logger = new Mock<ILogger<UserProvisioningService>>();
        _sut = new UserProvisioningService(_userRepo.Object, _logger.Object);
    }

    private static ClaimsPrincipal BuildPrincipal(IEnumerable<Claim> claims) =>
        new(new ClaimsIdentity(claims, "TestAuth"));

    private static User BuildUser(int userId = 7) => new()
    {
        UserId = userId,
        ExternalUserId = Sub,
        Email = Email,
        DisplayName = "Person Example",
        FirstName = "Person",
        LastName = "Example",
        RoleId = 1,
    };

    // ── ProvisionFromClaimsAsync ──────────────────────────────────────────────

    [Fact]
    public async Task ProvisionFromClaimsAsync_WithExistingUser_ReturnsExistingRowAndDoesNotInsert()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim("sub", Sub),
            new Claim(ClaimTypes.Email, Email),
        ]);
        User existing = BuildUser();
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeSameAs(existing);
        _userRepo.Verify(
            r => r.ProvisionAsync(
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<string?>(),
                It.IsAny<string?>(),
                It.IsAny<int>(),
                It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_WithNewUser_InsertsAndReturnsRow()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim("sub", Sub),
            new Claim(ClaimTypes.Email, Email),
            new Claim(ClaimTypes.GivenName, "Person"),
            new Claim(ClaimTypes.Surname, "Example"),
        ]);
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
        User created = BuildUser();
        _userRepo.Setup(r => r.ProvisionAsync(
                Sub, Email, "Person Example", "Person", "Example", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(created);

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeSameAs(created);
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_FallsBackFromSubToNameIdentifier()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim(ClaimTypes.NameIdentifier, Sub),
            new Claim(ClaimTypes.Email, Email),
        ]);
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync(BuildUser());

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_WithNoSubOrNameIdentifier_ReturnsFailure()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim(ClaimTypes.Email, Email),
        ]);

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("sub").And.Contain("NameIdentifier");
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_WithNoEmail_ReturnsFailure()
    {
        ClaimsPrincipal principal = BuildPrincipal([new Claim("sub", Sub)]);

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("email").And.Contain("scope");
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_PrefersNameClaimOverGivenPlusSurname()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim("sub", Sub),
            new Claim(ClaimTypes.Email, Email),
            new Claim(ClaimTypes.Name, "Display Name"),
            new Claim(ClaimTypes.GivenName, "First"),
            new Claim(ClaimTypes.Surname, "Last"),
        ]);
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
        _userRepo.Setup(r => r.ProvisionAsync(
                Sub, Email, "Display Name", "First", "Last", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(BuildUser());

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsSuccess.Should().BeTrue();
        _userRepo.Verify(r => r.ProvisionAsync(
                Sub, Email, "Display Name", "First", "Last", 1, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_FallsBackToFirstLast_WhenNameClaimAbsent()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim("sub", Sub),
            new Claim(ClaimTypes.Email, Email),
            new Claim("given_name", "Given"),
            new Claim("family_name", "Family"),
        ]);
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
        _userRepo.Setup(r => r.ProvisionAsync(
                Sub, Email, "Given Family", "Given", "Family", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(BuildUser());

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task ProvisionFromClaimsAsync_FallsBackToEmail_WhenNoNameAvailable()
    {
        ClaimsPrincipal principal = BuildPrincipal(
        [
            new Claim("sub", Sub),
            new Claim(ClaimTypes.Email, Email),
        ]);
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
        _userRepo.Setup(r => r.ProvisionAsync(
                Sub, Email, Email, string.Empty, string.Empty, 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(BuildUser());

        Result<User> result = await _sut.ProvisionFromClaimsAsync(principal);

        result.IsSuccess.Should().BeTrue();
    }

    // ── ProvisionAsync (admin path) ───────────────────────────────────────────

    [Fact]
    public async Task ProvisionAsync_WithEmptyExternalUserId_ReturnsFailure()
    {
        Result<User> result = await _sut.ProvisionAsync("", Email, "Display", null, null);
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("ExternalUserId");
    }

    [Fact]
    public async Task ProvisionAsync_WithEmptyEmail_ReturnsFailure()
    {
        Result<User> result = await _sut.ProvisionAsync(Sub, "", "Display", null, null);
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Email");
    }

    [Fact]
    public async Task ProvisionAsync_WithEmptyDisplayName_ReturnsFailure()
    {
        Result<User> result = await _sut.ProvisionAsync(Sub, Email, "", null, null);
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("DisplayName");
    }

    [Fact]
    public async Task ProvisionAsync_WithExistingUser_ReturnsExistingAndSkipsInsert()
    {
        User existing = BuildUser();
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);

        Result<User> result = await _sut.ProvisionAsync(Sub, Email, "Display", "F", "L");

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeSameAs(existing);
        _userRepo.Verify(r => r.ProvisionAsync(
                It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
                It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<int>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task ProvisionAsync_WithNewUser_InsertsRow()
    {
        _userRepo.Setup(r => r.GetByExternalUserIdAsync(Sub, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
        User created = BuildUser();
        _userRepo.Setup(r => r.ProvisionAsync(
                Sub, Email, "Display", "F", "L", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(created);

        Result<User> result = await _sut.ProvisionAsync(Sub, Email, "Display", "F", "L");

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeSameAs(created);
    }
}
