using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Calendar;
using VillaWolf.Application.Calendar.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/calendar")]
[Authorize]
public class CalendarController : ControllerBase
{
    private readonly ICalendarService _calendar;

    public CalendarController(ICalendarService calendar) => _calendar = calendar;

    [HttpGet("integrations")]
    public async Task<IActionResult> ListIntegrations(CancellationToken ct)
        => Ok(await _calendar.ListIntegrationsAsync(ct));

    [HttpPost("integrations")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Connect([FromBody] ConnectCalendarRequest request, CancellationToken ct)
        => (await _calendar.ConnectAsync(request, ct)).ToActionResult(this);

    [HttpPatch("integrations/{id:guid}/enable")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Enable(Guid id, CancellationToken ct)
        => (await _calendar.SetEnabledAsync(id, true, ct)).ToActionResult(this);

    [HttpPatch("integrations/{id:guid}/disable")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Disable(Guid id, CancellationToken ct)
        => (await _calendar.SetEnabledAsync(id, false, ct)).ToActionResult(this);

    [HttpDelete("integrations/{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Disconnect(Guid id, CancellationToken ct)
        => (await _calendar.DisconnectAsync(id, ct)).ToActionResult(this);

    /// <summary>Exports the appointment to the configured calendar (mocked) and stores its event id.</summary>
    [HttpPost("appointments/{appointmentId:guid}/export")]
    [Authorize(Roles = "Admin,Reception,Barber")]
    public async Task<IActionResult> Export(Guid appointmentId, CancellationToken ct)
        => (await _calendar.ExportAppointmentAsync(appointmentId, ct)).ToActionResult(this);
}
