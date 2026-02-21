using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Ara.Sections;

/// <summary>Manages the PM narrative section via <see cref="IAraPmSectionRepository"/>.</summary>
public sealed class AraPmSectionService : IAraPmSectionService
{
    private readonly IAraPmSectionRepository _repository;
    private readonly ILogger<AraPmSectionService> _logger;

    /// <summary>Initializes a new instance of <see cref="AraPmSectionService"/>.</summary>
    public AraPmSectionService(IAraPmSectionRepository repository, ILogger<AraPmSectionService> logger)
    {
        _repository = repository;
        _logger     = logger;
    }

    /// <inheritdoc/>
    public async Task<AraPmSectionDto?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        AraPmSection? section = await _repository.GetByAraIdAsync(araId, cancellationToken);
        return section is null ? null : ToDto(section);
    }

    /// <inheritdoc/>
    public async Task<Result> SaveAsync(int araId, SaveAraPmSectionRequest request, CancellationToken cancellationToken = default)
    {
        AraPmSection section = new()
        {
            AraId                 = araId,
            FundsInAdvance        = request.FundsInAdvance,
            ContractDefinization  = request.ContractDefinization,
            PertinentInformation  = request.PertinentInformation,
            WorkStarted           = request.WorkStarted,
            Consequence           = request.Consequence,
            CurrentStatus         = request.CurrentStatus,
            ChangeInScope         = request.ChangeInScope,
            ActionToClear         = request.ActionToClear,
            EarlyStartNecessary   = request.EarlyStartNecessary,
            OtherNecessary        = request.OtherNecessary,
        };

        await _repository.UpsertAsync(section, cancellationToken);
        _logger.LogInformation("Saved PM section for ARA {AraId}.", araId);
        return Result.Success();
    }

    private static AraPmSectionDto ToDto(AraPmSection s) =>
        new(s.AraPmSectionId, s.AraId, s.FundsInAdvance, s.ContractDefinization,
            s.PertinentInformation, s.WorkStarted, s.Consequence, s.CurrentStatus,
            s.ChangeInScope, s.ActionToClear, s.EarlyStartNecessary, s.OtherNecessary);
}
