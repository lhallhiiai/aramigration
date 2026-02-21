using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Ara.Sections;

/// <summary>
/// Manages the Controller section via <see cref="IAraControllerSectionRepository"/>.
/// TotalCost and TotalFee are recalculated by the stored procedure on each save.
/// </summary>
public sealed class AraControllerSectionService : IAraControllerSectionService
{
    private readonly IAraControllerSectionRepository _repository;
    private readonly ILogger<AraControllerSectionService> _logger;

    /// <summary>Initializes a new instance of <see cref="AraControllerSectionService"/>.</summary>
    public AraControllerSectionService(
        IAraControllerSectionRepository repository,
        ILogger<AraControllerSectionService> logger)
    {
        _repository = repository;
        _logger     = logger;
    }

    /// <inheritdoc/>
    public async Task<AraControllerSectionDto?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        AraControllerSection? section = await _repository.GetByAraIdAsync(araId, cancellationToken);
        return section is null ? null : ToDto(section);
    }

    /// <inheritdoc/>
    public async Task<Result> SaveAsync(int araId, int controllerId, SaveAraControllerSectionRequest request, CancellationToken cancellationToken = default)
    {
        AraControllerSection section = new()
        {
            AraId         = araId,
            ControllerId  = controllerId,
            InterestImpact = request.InterestImpact,
            BurnRate      = request.BurnRate,
            IncurredCost  = request.IncurredCost,
            IncurredFee   = request.IncurredFee,
            Company       = request.Company,
        };

        await _repository.UpsertAsync(section, cancellationToken);
        _logger.LogInformation("Saved Controller section for ARA {AraId}.", araId);
        return Result.Success();
    }

    private static AraControllerSectionDto ToDto(AraControllerSection s) =>
        new(s.AraControllerSectionId, s.AraId, s.ControllerId, s.InterestImpact,
            s.BurnRate, s.TotalCost, s.TotalFee, s.IncurredCost, s.IncurredFee, s.Company);
}
