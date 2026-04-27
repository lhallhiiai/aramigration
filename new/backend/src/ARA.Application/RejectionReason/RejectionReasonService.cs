using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.RejectionReason;

/// <summary>
/// Read-only lookup service for rejection reason codes via <see cref="IRejectionReasonRepository"/>.
/// </summary>
public sealed class RejectionReasonService : IRejectionReasonService
{
    private readonly IRejectionReasonRepository _repository;
    private readonly ILogger<RejectionReasonService> _logger;

    /// <summary>Initializes a new instance of <see cref="RejectionReasonService"/>.</summary>
    public RejectionReasonService(IRejectionReasonRepository repository, ILogger<RejectionReasonService> logger)
    {
        _repository = repository;
        _logger     = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<RejectionReasonDto>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.RejectionReason> reasons =
            await _repository.GetAllActiveAsync(cancellationToken);
        return reasons
            .Select(r => new RejectionReasonDto(r.RejectionReasonId, r.Description, r.DisplayOrder))
            .ToList()
            .AsReadOnly();
    }
}
