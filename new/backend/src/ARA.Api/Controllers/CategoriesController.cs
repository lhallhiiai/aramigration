using ARA.Application.Category;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Exposes ARA risk category lookup data.</summary>
[ApiController]
[Route("api/categories")]
[Authorize]
public sealed class CategoriesController : ControllerBase
{
    private readonly ICategoryService _categoryService;
    private readonly ILogger<CategoriesController> _logger;

    /// <summary>Initializes a new instance of <see cref="CategoriesController"/>.</summary>
    public CategoriesController(ICategoryService categoryService, ILogger<CategoriesController> logger)
    {
        _categoryService = categoryService;
        _logger = logger;
    }

    /// <summary>Returns all ARA risk categories.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        IReadOnlyList<CategoryDto> categories = await _categoryService.GetAllAsync(cancellationToken);
        return Ok(categories);
    }

    /// <summary>Returns a single category by ID.</summary>
    [HttpGet("{categoryId:int}")]
    public async Task<IActionResult> GetById(int categoryId, CancellationToken cancellationToken)
    {
        ARA.Application.Common.Result<CategoryDto> result = await _categoryService.GetByIdAsync(categoryId, cancellationToken);
        if (result.IsFailure)
            return NotFound(result.Error);
        return Ok(result.Value);
    }
}
