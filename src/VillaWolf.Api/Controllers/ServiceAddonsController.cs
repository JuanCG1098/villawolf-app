using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Catalog;
using VillaWolf.Application.Catalog.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/service-addons")]
[Authorize]
public class ServiceAddonsController : ControllerBase
{
    private readonly ICatalogService _catalog;

    public ServiceAddonsController(ICatalogService catalog) => _catalog = catalog;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] bool includeInactive, CancellationToken ct)
        => Ok(await _catalog.ListAddonsAsync(includeInactive, ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
        => (await _catalog.GetAddonAsync(id, ct)).ToActionResult(this);

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateAddonRequest request, CancellationToken ct)
        => (await _catalog.CreateAddonAsync(request, ct)).ToActionResult(this);

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateAddonRequest request, CancellationToken ct)
        => (await _catalog.UpdateAddonAsync(id, request, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/activate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Activate(Guid id, CancellationToken ct)
        => (await _catalog.SetAddonActiveAsync(id, true, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/deactivate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Deactivate(Guid id, CancellationToken ct)
        => (await _catalog.SetAddonActiveAsync(id, false, ct)).ToActionResult(this);
}
