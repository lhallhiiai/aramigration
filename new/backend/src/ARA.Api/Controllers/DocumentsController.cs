using ARA.Application.Document;
using ARA.Application.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Manages PDF document uploads attached to an ARA.</summary>
[ApiController]
[Route("api/aras/{araId:int}/documents")]
[Authorize]
public sealed class DocumentsController : ControllerBase
{
    private readonly IDocumentService _documentService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<DocumentsController> _logger;

    /// <summary>Initializes a new instance of <see cref="DocumentsController"/>.</summary>
    public DocumentsController(
        IDocumentService documentService,
        ICurrentUserService currentUserService,
        ILogger<DocumentsController> logger)
    {
        _documentService    = documentService;
        _currentUserService = currentUserService;
        _logger             = logger;
    }

    /// <summary>Returns all document records for the given ARA.</summary>
    [HttpGet]
    public async Task<IActionResult> GetByAraId(int araId, CancellationToken cancellationToken)
    {
        IReadOnlyList<AraDocumentDto> docs = await _documentService.GetByAraIdAsync(araId, cancellationToken);
        return Ok(docs);
    }

    /// <summary>
    /// Persists a document metadata record after the file has been uploaded to Blob Storage.
    /// Returns the new AraDocumentId.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create(int araId, [FromBody] CreateDocumentRequest request, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result<int> result = await _documentService.CreateAsync(araId, currentUser.UserId, request, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return Ok(result.Value);
    }

    /// <summary>Removes a document metadata record.</summary>
    [HttpDelete("{araDocumentId:int}")]
    public async Task<IActionResult> Delete(int araId, int araDocumentId, CancellationToken cancellationToken)
    {
        ARA.Application.Common.Result result = await _documentService.DeleteAsync(araDocumentId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }
}
