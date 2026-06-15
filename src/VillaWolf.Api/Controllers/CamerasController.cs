using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Cameras;
using VillaWolf.Application.Cameras.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/cameras")]
[Authorize]
public class CamerasController : ControllerBase
{
    private readonly ICameraService _cameras;

    public CamerasController(ICameraService cameras) => _cameras = cameras;

    [HttpGet]
    public async Task<IActionResult> List(CancellationToken ct) => Ok(await _cameras.ListAsync(ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
        => (await _cameras.GetAsync(id, ct)).ToActionResult(this);

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateCameraRequest request, CancellationToken ct)
        => (await _cameras.CreateAsync(request, ct)).ToActionResult(this);

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCameraRequest request, CancellationToken ct)
        => (await _cameras.UpdateAsync(id, request, ct)).ToActionResult(this);

    [HttpPatch("{id:guid}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> SetStatus(Guid id, [FromBody] SetCameraStatusRequest request, CancellationToken ct)
        => (await _cameras.SetStatusAsync(id, request.Status, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/battery")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> ReportBattery(Guid id, [FromBody] ReportBatteryRequest request, CancellationToken ct)
        => (await _cameras.ReportBatteryAsync(id, request.Level, ct)).ToActionResult(this);

    [HttpGet("{id:guid}/maintenance")]
    public async Task<IActionResult> Maintenance(Guid id, CancellationToken ct)
        => (await _cameras.ListMaintenanceAsync(id, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/maintenance")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> RegisterMaintenance(Guid id, [FromBody] CreateMaintenanceRequest request, CancellationToken ct)
        => (await _cameras.RegisterMaintenanceAsync(id, request, ct)).ToActionResult(this);
}
