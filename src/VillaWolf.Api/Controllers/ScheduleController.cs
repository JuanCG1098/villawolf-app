using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Scheduling;
using VillaWolf.Application.Scheduling.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/schedule")]
[Authorize]
public class ScheduleController : ControllerBase
{
    private readonly ISchedulingService _scheduling;

    public ScheduleController(ISchedulingService scheduling) => _scheduling = scheduling;

    // ----- Working hours -----

    [HttpGet("working-hours")]
    public async Task<IActionResult> ListWorkingHours([FromQuery] Guid? employeeId, CancellationToken ct)
        => Ok(await _scheduling.ListWorkingHoursAsync(employeeId, ct));

    [HttpPost("working-hours")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> CreateWorkingHour([FromBody] CreateWorkingHourRequest request, CancellationToken ct)
        => (await _scheduling.CreateWorkingHourAsync(request, ct)).ToActionResult(this);

    [HttpDelete("working-hours/{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteWorkingHour(Guid id, CancellationToken ct)
        => (await _scheduling.DeleteWorkingHourAsync(id, ct)).ToActionResult(this);

    // ----- Time blocks -----

    [HttpGet("time-blocks")]
    public async Task<IActionResult> ListTimeBlocks(
        [FromQuery] Guid? employeeId, [FromQuery] DateTime? fromUtc, [FromQuery] DateTime? toUtc, CancellationToken ct)
        => Ok(await _scheduling.ListTimeBlocksAsync(employeeId, fromUtc, toUtc, ct));

    [HttpPost("time-blocks")]
    [Authorize(Roles = "Admin,Reception")]
    public async Task<IActionResult> CreateTimeBlock([FromBody] CreateTimeBlockRequest request, CancellationToken ct)
        => (await _scheduling.CreateTimeBlockAsync(request, ct)).ToActionResult(this);

    [HttpDelete("time-blocks/{id:guid}")]
    [Authorize(Roles = "Admin,Reception")]
    public async Task<IActionResult> DeleteTimeBlock(Guid id, CancellationToken ct)
        => (await _scheduling.DeleteTimeBlockAsync(id, ct)).ToActionResult(this);

    // ----- Availability -----

    [HttpGet("free-slots")]
    public async Task<IActionResult> FreeSlots(
        [FromQuery] Guid employeeId, [FromQuery] DateOnly date, [FromQuery] Guid? serviceId, CancellationToken ct)
        => (await _scheduling.GetFreeSlotsAsync(employeeId, date, serviceId, ct)).ToActionResult(this);
}
