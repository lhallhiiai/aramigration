using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Clin;

/// <summary>Manages CLIN worksheet entries via <see cref="IClinEntryRepository"/>.</summary>
public sealed class ClinEntryService : IClinEntryService
{
    private readonly IClinEntryRepository _clinRepository;
    private readonly IAraRepository _araRepository;
    private readonly ILogger<ClinEntryService> _logger;

    /// <summary>Initializes a new instance of <see cref="ClinEntryService"/>.</summary>
    public ClinEntryService(
        IClinEntryRepository clinRepository,
        IAraRepository araRepository,
        ILogger<ClinEntryService> logger)
    {
        _clinRepository = clinRepository;
        _araRepository  = araRepository;
        _logger         = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ClinEntryDto>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<ClinEntry> entries = await _clinRepository.GetByAraIdAsync(araId, cancellationToken);
        return entries.Select(ToDto).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<Result<int>> CreateAsync(int araId, CreateClinRequest request, CancellationToken cancellationToken = default)
    {
        ARA.Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result<int>.Failure($"ARA {araId} not found.");

        IReadOnlyList<ClinEntry> existing = await _clinRepository.GetByAraIdAsync(araId, cancellationToken);
        bool duplicate = existing.Any(e => string.Equals(e.ClinNumber, request.ClinNumber, StringComparison.OrdinalIgnoreCase));
        if (duplicate)
            return Result<int>.Failure($"CLIN {request.ClinNumber} has already been added to this ARA.");

        ClinEntry entry = new()
        {
            AraId          = araId,
            ClinNumber     = request.ClinNumber,
            ClinDescription = request.ClinDescription,
            Cost           = request.Cost,
            Fee            = request.Fee,
        };

        int clinEntryId = await _clinRepository.CreateAsync(entry, cancellationToken);
        _logger.LogInformation("Created CLIN entry {ClinEntryId} for ARA {AraId}.", clinEntryId, araId);
        return Result<int>.Success(clinEntryId);
    }

    /// <inheritdoc/>
    public async Task<Result> UpdateAsync(UpdateClinRequest request, CancellationToken cancellationToken = default)
    {
        ClinEntry entry = new()
        {
            ClinEntryId    = request.ClinEntryId,
            ClinNumber     = request.ClinNumber,
            ClinDescription = request.ClinDescription,
            Cost           = request.Cost,
            Fee            = request.Fee,
        };

        await _clinRepository.UpdateAsync(entry, cancellationToken);
        _logger.LogInformation("Updated CLIN entry {ClinEntryId}.", request.ClinEntryId);
        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> DeleteAsync(int clinEntryId, CancellationToken cancellationToken = default)
    {
        await _clinRepository.DeleteAsync(clinEntryId, cancellationToken);
        _logger.LogInformation("Deleted CLIN entry {ClinEntryId}.", clinEntryId);
        return Result.Success();
    }

    private static ClinEntryDto ToDto(ClinEntry e) =>
        new(e.ClinEntryId, e.AraId, e.ClinNumber, e.ClinDescription, e.Cost, e.Fee, e.Total);
}
