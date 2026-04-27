using ARA.Application.Common;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Delegation;

/// <summary>
/// Manages user delegation of approval authority with business rule enforcement.
/// </summary>
public sealed class DelegationService : IDelegationService
{
    private readonly IDelegationRepository _delegationRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<DelegationService> _logger;

    /// <summary>Initializes a new instance of <see cref="DelegationService"/>.</summary>
    public DelegationService(
        IDelegationRepository delegationRepository,
        IUserRepository userRepository,
        ILogger<DelegationService> logger)
    {
        _delegationRepository = delegationRepository;
        _userRepository       = userRepository;
        _logger               = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<DelegationDto>> GetActiveDelegationsAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Delegation> delegations =
            await _delegationRepository.GetActiveDelegationsAsync(cancellationToken);

        List<DelegationDto> results = [];
        foreach (Domain.Entities.Delegation delegation in delegations)
        {
            Domain.Entities.User? delegator = await _userRepository.GetByIdAsync(delegation.DelegatorUserId, cancellationToken);
            Domain.Entities.User? delegatee = await _userRepository.GetByIdAsync(delegation.DelegateeUserId, cancellationToken);

            results.Add(new DelegationDto(
                delegation.DelegationId,
                delegation.DelegatorUserId,
                delegator?.DisplayName ?? "Unknown",
                delegation.DelegateeUserId,
                delegatee?.DisplayName ?? "Unknown",
                delegation.StartDate,
                delegation.EndDate,
                delegation.IsActive));
        }

        return results.AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<Result<int>> CreateDelegationAsync(
        CreateDelegationRequest request, int delegatorUserId, CancellationToken cancellationToken = default)
    {
        if (delegatorUserId == request.DelegateeUserId)
            return Result<int>.Failure("A user cannot delegate to themselves.");

        Domain.Entities.User? delegator = await _userRepository.GetByIdAsync(delegatorUserId, cancellationToken);
        if (delegator is null)
            return Result<int>.Failure("Delegator user not found.");

        Domain.Entities.User? delegatee = await _userRepository.GetByIdAsync(request.DelegateeUserId, cancellationToken);
        if (delegatee is null || delegatee.IsInactive)
            return Result<int>.Failure("Delegatee user not found or inactive.");

        Domain.Entities.Delegation? existingDelegation =
            await _delegationRepository.GetActiveDelegationForUserAsync(delegatorUserId, cancellationToken);
        if (existingDelegation is not null)
            return Result<int>.Failure("Delegator already has an active delegation. Deactivate it before creating a new one.");

        if (request.EndDate <= request.StartDate)
            return Result<int>.Failure("End date must be after start date.");

        Domain.Entities.Delegation delegation = new()
        {
            DelegatorUserId = delegatorUserId,
            DelegateeUserId = request.DelegateeUserId,
            StartDate       = request.StartDate,
            EndDate         = request.EndDate,
        };

        int delegationId = await _delegationRepository.CreateAsync(delegation, cancellationToken);
        _logger.LogInformation("Delegation {DelegationId} created: user {DelegatorId} → user {DelegateeId}.",
            delegationId, delegatorUserId, request.DelegateeUserId);
        return Result<int>.Success(delegationId);
    }

    /// <inheritdoc/>
    public async Task<Result> DeactivateDelegationAsync(
        int delegationId, int userId, CancellationToken cancellationToken = default)
    {
        await _delegationRepository.DeactivateAsync(delegationId, cancellationToken);
        _logger.LogInformation("Delegation {DelegationId} deactivated by user {UserId}.", delegationId, userId);
        return Result.Success();
    }
}
