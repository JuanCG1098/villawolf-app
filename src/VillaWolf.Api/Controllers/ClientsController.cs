using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Clients;
using VillaWolf.Application.Clients.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/clients")]
[Authorize]
public class ClientsController : ControllerBase
{
    private readonly IClientService _clients;

    public ClientsController(IClientService clients) => _clients = clients;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? search, [FromQuery] bool includeInactive, CancellationToken ct)
        => Ok(await _clients.ListAsync(search, includeInactive, ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
        => (await _clients.GetAsync(id, ct)).ToActionResult(this);

    [HttpGet("{id:guid}/appointments")]
    public async Task<IActionResult> History(Guid id, CancellationToken ct)
        => (await _clients.GetHistoryAsync(id, ct)).ToActionResult(this);

    [HttpPost]
    [Authorize(Roles = "Admin,Reception")]
    public async Task<IActionResult> Create([FromBody] CreateClientRequest request, CancellationToken ct)
        => (await _clients.CreateAsync(request, ct)).ToActionResult(this);

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin,Reception")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateClientRequest request, CancellationToken ct)
        => (await _clients.UpdateAsync(id, request, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/activate")]
    [Authorize(Roles = "Admin,Reception")]
    public async Task<IActionResult> Activate(Guid id, CancellationToken ct)
        => (await _clients.SetActiveAsync(id, true, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/deactivate")]
    [Authorize(Roles = "Admin,Reception")]
    public async Task<IActionResult> Deactivate(Guid id, CancellationToken ct)
        => (await _clients.SetActiveAsync(id, false, ct)).ToActionResult(this);
}
