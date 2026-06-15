using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Calendar.Dtos;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Calendar;

public interface ICalendarService
{
    Task<IReadOnlyList<CalendarIntegrationDto>> ListIntegrationsAsync(CancellationToken ct = default);
    Task<Result<CalendarIntegrationDto>> ConnectAsync(ConnectCalendarRequest request, CancellationToken ct = default);
    Task<Result> SetEnabledAsync(Guid id, bool enabled, CancellationToken ct = default);
    Task<Result> DisconnectAsync(Guid id, CancellationToken ct = default);
    Task<Result<AppointmentSyncResultDto>> ExportAppointmentAsync(Guid appointmentId, CancellationToken ct = default);
}

/// <summary>
/// Orchestrates Google Calendar links and appointment export. The actual event creation is delegated
/// to the configured <see cref="ICalendarSyncProvider"/> (mocked for now), keeping it decoupled.
/// Exporting an already-synced appointment is a no-op (avoids duplicates).
/// </summary>
public sealed class CalendarService : ICalendarService
{
    private readonly IAppDbContext _db;
    private readonly ICalendarSyncProvider _provider;

    public CalendarService(IAppDbContext db, ICalendarSyncProvider provider)
    {
        _db = db;
        _provider = provider;
    }

    public async Task<IReadOnlyList<CalendarIntegrationDto>> ListIntegrationsAsync(CancellationToken ct = default)
    {
        var items = await _db.GoogleCalendarIntegrations.OrderBy(i => i.OwnerType).ToListAsync(ct);
        return items.Select(i => i.ToDto()).ToList();
    }

    public async Task<Result<CalendarIntegrationDto>> ConnectAsync(ConnectCalendarRequest request, CancellationToken ct = default)
    {
        if (request.OwnerType == CalendarOwnerType.Employee)
        {
            if (request.EmployeeId is null)
                return Result.Failure<CalendarIntegrationDto>(Error.Validation("calendar.employee_required", "An employee calendar requires an employee id."));
            if (!await _db.Employees.AnyAsync(e => e.Id == request.EmployeeId, ct))
                return Result.Failure<CalendarIntegrationDto>(Error.Validation("calendar.employee_invalid", "The employee does not exist."));
        }

        var existing = request.OwnerType == CalendarOwnerType.Employee
            ? await _db.GoogleCalendarIntegrations.FirstOrDefaultAsync(
                i => i.OwnerType == CalendarOwnerType.Employee && i.EmployeeId == request.EmployeeId, ct)
            : await _db.GoogleCalendarIntegrations.FirstOrDefaultAsync(
                i => i.OwnerType == CalendarOwnerType.Business, ct);

        if (existing is not null)
        {
            existing.Reconnect(request.GoogleCalendarId);
        }
        else
        {
            existing = new GoogleCalendarIntegration(request.OwnerType, request.EmployeeId, request.GoogleCalendarId);
            _db.GoogleCalendarIntegrations.Add(existing);
        }

        await _db.SaveChangesAsync(ct);
        return existing.ToDto();
    }

    public async Task<Result> SetEnabledAsync(Guid id, bool enabled, CancellationToken ct = default)
    {
        var integration = await _db.GoogleCalendarIntegrations.FirstOrDefaultAsync(i => i.Id == id, ct);
        if (integration is null) return Result.Failure(Error.NotFound("calendar.not_found", "Integration not found."));

        integration.SetSyncEnabled(enabled);
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    public async Task<Result> DisconnectAsync(Guid id, CancellationToken ct = default)
    {
        var integration = await _db.GoogleCalendarIntegrations.FirstOrDefaultAsync(i => i.Id == id, ct);
        if (integration is null) return Result.Failure(Error.NotFound("calendar.not_found", "Integration not found."));

        _db.GoogleCalendarIntegrations.Remove(integration);
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    public async Task<Result<AppointmentSyncResultDto>> ExportAppointmentAsync(Guid appointmentId, CancellationToken ct = default)
    {
        var appointment = await _db.Appointments.FirstOrDefaultAsync(a => a.Id == appointmentId, ct);
        if (appointment is null)
            return Result.Failure<AppointmentSyncResultDto>(Error.NotFound("appointment.not_found", "Appointment not found."));

        // Already exported — return the existing id without creating a duplicate.
        if (!string.IsNullOrEmpty(appointment.GoogleEventId))
            return new AppointmentSyncResultDto(appointment.Id, appointment.GoogleEventId!, AlreadySynced: true);

        if (!_provider.IsEnabled)
            return Result.Failure<AppointmentSyncResultDto>(Error.Conflict("calendar.disabled", "Calendar sync is disabled."));

        var calendarId = await ResolveCalendarIdAsync(appointment.EmployeeId, ct);
        var data = new CalendarEventData(
            appointment.Id,
            $"{appointment.ServiceNameSnapshot} — VILLAWOLF",
            appointment.StartUtc,
            appointment.EndUtc,
            calendarId,
            appointment.InternalNotes);

        var created = await _provider.CreateEventAsync(data, ct);
        if (created.IsFailure)
            return Result.Failure<AppointmentSyncResultDto>(created.Error);

        appointment.LinkGoogleEvent(created.Value);
        await _db.SaveChangesAsync(ct);
        return new AppointmentSyncResultDto(appointment.Id, created.Value, AlreadySynced: false);
    }

    private async Task<string?> ResolveCalendarIdAsync(Guid employeeId, CancellationToken ct)
    {
        var employeeCalendar = await _db.GoogleCalendarIntegrations.FirstOrDefaultAsync(
            i => i.OwnerType == CalendarOwnerType.Employee && i.EmployeeId == employeeId && i.SyncEnabled, ct);
        if (employeeCalendar is not null) return employeeCalendar.GoogleCalendarId;

        var businessCalendar = await _db.GoogleCalendarIntegrations.FirstOrDefaultAsync(
            i => i.OwnerType == CalendarOwnerType.Business && i.SyncEnabled, ct);
        return businessCalendar?.GoogleCalendarId;
    }
}
