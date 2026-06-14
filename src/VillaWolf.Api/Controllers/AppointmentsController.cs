using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Appointments;
using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/appointments")]
[Authorize]
public class AppointmentsController : ControllerBase
{
    private readonly IAppointmentService _appointments;

    public AppointmentsController(IAppointmentService appointments) => _appointments = appointments;

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] DateTime? fromUtc,
        [FromQuery] DateTime? toUtc,
        [FromQuery] Guid? employeeId,
        [FromQuery] Guid? clientId,
        [FromQuery] AppointmentStatus? status,
        CancellationToken ct)
        => Ok(await _appointments.ListAsync(fromUtc, toUtc, employeeId, clientId, status, ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
        => (await _appointments.GetAsync(id, ct)).ToActionResult(this);

    [HttpPost]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Create([FromBody] CreateAppointmentRequest request, CancellationToken ct)
    {
        // Overbooking is only honoured when explicitly requested by an Admin.
        var allowOverbooking = request.AllowOverbooking && User.IsInRole("Admin");
        return (await _appointments.CreateAsync(request, allowOverbooking, ct)).ToActionResult(this);
    }

    [HttpPut("{id:guid}/reschedule")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Reschedule(Guid id, [FromBody] RescheduleAppointmentRequest request, CancellationToken ct)
        => (await _appointments.RescheduleAsync(id, request.NewStartUtc, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/confirm")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Confirm(Guid id, CancellationToken ct)
        => (await _appointments.ConfirmAsync(id, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/start")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Start(Guid id, CancellationToken ct)
        => (await _appointments.StartAsync(id, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/complete")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Complete(Guid id, CancellationToken ct)
        => (await _appointments.CompleteAsync(id, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/cancel")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Cancel(Guid id, CancellationToken ct)
        => (await _appointments.CancelAsync(id, ct)).ToActionResult(this);

    [HttpPost("{id:guid}/no-show")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> NoShow(Guid id, CancellationToken ct)
        => (await _appointments.NoShowAsync(id, ct)).ToActionResult(this);
}
