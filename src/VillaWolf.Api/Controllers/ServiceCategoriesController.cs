using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Catalog;
using VillaWolf.Application.Catalog.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/service-categories")]
[Authorize]
public class ServiceCategoriesController : ControllerBase
{
    private readonly ICatalogService _catalog;

    public ServiceCategoriesController(ICatalogService catalog) => _catalog = catalog;

    [HttpGet]
    public async Task<IActionResult> List(CancellationToken ct)
        => Ok(await _catalog.ListCategoriesAsync(ct));

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateCategoryRequest request, CancellationToken ct)
        => (await _catalog.CreateCategoryAsync(request, ct)).ToActionResult(this);
}
