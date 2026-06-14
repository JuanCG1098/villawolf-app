using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Catalog;
using VillaWolf.Application.Catalog.Dtos;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/services")]
[Authorize]
public class ServicesController : ControllerBase
{
    private readonly ICatalogService _catalog;

    public ServicesController(ICatalogService catalog) => _catalog = catalog;

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] bool includeInactive,
        [FromQuery] ServiceTargetAudience? audience,
        [FromQuery] Guid? categoryId,
        CancellationToken ct)
        => Ok(await _catalog.ListServicesAsync(includeInactive, audience, categoryId, ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
        => (await _catalog.GetServiceAsync(id, ct)).ToActionResult(this);

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateServiceRequest request, CancellationToken ct)
        => (await _catalog.CreateServiceAsync(request, ct)).ToActionResult(this);

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateServiceRequest request, CancellationToken ct)
        => (await _catalog.UpdateServiceAsync(id, request, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/activate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Activate(Guid id, CancellationToken ct)
        => (await _catalog.SetServiceActiveAsync(id, true, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/deactivate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Deactivate(Guid id, CancellationToken ct)
        => (await _catalog.SetServiceActiveAsync(id, false, ct)).ToActionResult(this);
}
