using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Users;

/// <summary>Reads user data from the repository.</summary>
public sealed class UserService : IUserService
{
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger;

    /// <summary>Initializes a new instance of <see cref="UserService"/>.</summary>
    public UserService(IUserRepository repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<UserDto>> GetByRoleAsync(UserRole role, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<User> users = await _repository.GetByRoleAsync(role, cancellationToken);
        return users.Select(ToDto).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<UserDto>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<User> users = await _repository.GetAllActiveAsync(cancellationToken);
        return users.Select(ToDto).ToList().AsReadOnly();
    }

    internal static UserDto ToDto(User u) =>
        new(u.UserId, u.DisplayName, u.FirstName, u.LastName, u.Email, u.Role, u.JobTitleId);
}
