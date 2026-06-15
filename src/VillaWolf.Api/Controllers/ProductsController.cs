using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Inventory;
using VillaWolf.Application.Inventory.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/products")]
[Authorize]
public class ProductsController : ControllerBase
{
    private readonly IInventoryService _inventory;

    public ProductsController(IInventoryService inventory) => _inventory = inventory;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] bool includeInactive, [FromQuery] bool lowStockOnly, CancellationToken ct)
        => Ok(await _inventory.ListProductsAsync(includeInactive, lowStockOnly, ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
        => (await _inventory.GetProductAsync(id, ct)).ToActionResult(this);

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateProductRequest request, CancellationToken ct)
        => (await _inventory.CreateProductAsync(request, ct)).ToActionResult(this);

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateProductRequest request, CancellationToken ct)
        => (await _inventory.UpdateProductAsync(id, request, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/activate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Activate(Guid id, CancellationToken ct)
        => (await _inventory.SetProductActiveAsync(id, true, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/deactivate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Deactivate(Guid id, CancellationToken ct)
        => (await _inventory.SetProductActiveAsync(id, false, ct)).ToActionResult(this);

    [HttpGet("{id:guid}/movements")]
    public async Task<IActionResult> Movements(Guid id, CancellationToken ct)
        => Ok(await _inventory.ListMovementsAsync(id, ct));

    [HttpPost("movements")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> RegisterMovement([FromBody] CreateMovementRequest request, CancellationToken ct)
        => (await _inventory.RegisterMovementAsync(request, ct)).ToActionResult(this);
}
