using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Application.Scheduling;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Appointments;

public sealed class AppointmentService : IAppointmentService
{
    private readonly IAppDbContext _db;
    private readonly ISchedulingService _scheduling;

    public AppointmentService(IAppDbContext db, ISchedulingService scheduling)
    {
        _db = db;
        _scheduling = scheduling;
    }

    public async Task<IReadOnlyList<AppointmentListItemDto>> ListAsync(
        DateTime? fromUtc, DateTime? toUtc, Guid? employeeId, Guid? clientId, AppointmentStatus? status,
        CancellationToken ct = default)
    {
        var query = _db.Appointments.AsQueryable();
        if (fromUtc is not null) query = query.Where(a => a.StartUtc >= fromUtc);
        if (toUtc is not null) query = query.Where(a => a.StartUtc < toUtc);
        if (employeeId is not null) query = query.Where(a => a.EmployeeId == employeeId);
        if (clientId is not null) query = query.Where(a => a.ClientId == clientId);
        if (status is not null) query = query.Where(a => a.Status == status);

        var appointments = await query.OrderBy(a => a.StartUtc).ToListAsync(ct);
        return appointments.Select(a => a.ToListItem()).ToList();
    }

    public async Task<Result<AppointmentDto>> GetAsync(Guid id, CancellationToken ct = default)
    {
        var appointment = await _db.Appointments.Include(a => a.Addons).FirstOrDefaultAsync(a => a.Id == id, ct);
        return appointment is null
            ? Result.Failure<AppointmentDto>(Error.NotFound("appointment.not_found", "Appointment not found."))
            : appointment.ToDto();
    }

    public async Task<Result<AppointmentDto>> CreateAsync(CreateAppointmentRequest request, bool allowOverbooking, CancellationToken ct = default)
    {
        var service = await _db.Services.FirstOrDefaultAsync(s => s.Id == request.ServiceId && s.IsActive, ct);
        if (service is null)
            return Result.Failure<AppointmentDto>(Error.Validation("appointment.service_invalid", "The service does not exist or is inactive."));

        if (!await _db.Clients.AnyAsync(c => c.Id == request.ClientId && c.IsActive, ct))
            return Result.Failure<AppointmentDto>(Error.Validation("appointment.client_invalid", "The client does not exist or is inactive."));

        if (!await _db.Employees.AnyAsync(e => e.Id == request.EmployeeId && e.IsActive, ct))
            return Result.Failure<AppointmentDto>(Error.Validation("appointment.employee_invalid", "The employee does not exist or is inactive."));

        var appointment = new Appointment(request.ClientId, request.EmployeeId, service, request.StartUtc,
            request.BookingChannel, request.InternalNotes, isOverbooking: allowOverbooking);

        if (request.AddonIds is { Count: > 0 })
        {
            var addons = await _db.ServiceAddons
                .Where(a => request.AddonIds.Contains(a.Id) && a.IsActive)
                .ToListAsync(ct);
            foreach (var addon in addons) appointment.AddAddon(addon);
        }

        // Friendly availability validation (working hours, blocks, overlap) unless this is an
        // admin-authorized overbooking. The DB exclusion constraint remains the final guard.
        if (!allowOverbooking)
        {
            var availability = await _scheduling.EnsureAvailableAsync(
                request.EmployeeId, appointment.StartUtc, appointment.TotalDurationMinutes, ct: ct);
            if (availability.IsFailure)
                return Result.Failure<AppointmentDto>(availability.Error);
        }

        _db.Appointments.Add(appointment);

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (IsOverlap(ex))
        {
            return Result.Failure<AppointmentDto>(Error.Conflict(
                "appointment.overlap", "The employee already has an appointment in that time range."));
        }

        return appointment.ToDto();
    }

    public async Task<Result<AppointmentDto>> RescheduleAsync(Guid id, DateTime newStartUtc, CancellationToken ct = default)
    {
        var appointment = await _db.Appointments.Include(a => a.Addons).FirstOrDefaultAsync(a => a.Id == id, ct);
        if (appointment is null)
            return Result.Failure<AppointmentDto>(Error.NotFound("appointment.not_found", "Appointment not found."));

        if (!appointment.IsOverbooking)
        {
            var availability = await _scheduling.EnsureAvailableAsync(
                appointment.EmployeeId, newStartUtc, appointment.TotalDurationMinutes, appointment.Id, ct);
            if (availability.IsFailure)
                return Result.Failure<AppointmentDto>(availability.Error);
        }

        try
        {
            appointment.Reschedule(newStartUtc);
            await _db.SaveChangesAsync(ct);
        }
        catch (InvalidOperationException ex)
        {
            return Result.Failure<AppointmentDto>(Error.Conflict("appointment.invalid_transition", ex.Message));
        }
        catch (DbUpdateException ex) when (IsOverlap(ex))
        {
            return Result.Failure<AppointmentDto>(Error.Conflict(
                "appointment.overlap", "The employee already has an appointment in that time range."));
        }

        return appointment.ToDto();
    }

    public Task<Result<AppointmentDto>> ConfirmAsync(Guid id, CancellationToken ct = default)
        => TransitionAsync(id, a => a.Confirm(), ct);

    public Task<Result<AppointmentDto>> StartAsync(Guid id, CancellationToken ct = default)
        => TransitionAsync(id, a => a.Start(), ct);

    public Task<Result<AppointmentDto>> CompleteAsync(Guid id, CancellationToken ct = default)
        => TransitionAsync(id, a => a.Complete(), ct);

    public Task<Result<AppointmentDto>> CancelAsync(Guid id, CancellationToken ct = default)
        => TransitionAsync(id, a => a.Cancel(), ct);

    public Task<Result<AppointmentDto>> NoShowAsync(Guid id, CancellationToken ct = default)
        => TransitionAsync(id, a => a.MarkNoShow(), ct);

    private async Task<Result<AppointmentDto>> TransitionAsync(Guid id, Action<Appointment> transition, CancellationToken ct)
    {
        var appointment = await _db.Appointments.Include(a => a.Addons).FirstOrDefaultAsync(a => a.Id == id, ct);
        if (appointment is null)
            return Result.Failure<AppointmentDto>(Error.NotFound("appointment.not_found", "Appointment not found."));

        try
        {
            transition(appointment);
        }
        catch (InvalidOperationException ex)
        {
            return Result.Failure<AppointmentDto>(Error.Conflict("appointment.invalid_transition", ex.Message));
        }

        await _db.SaveChangesAsync(ct);
        return appointment.ToDto();
    }

    // The DB exclusion constraint (ex_appointments_no_overlap) is the source of truth for overlaps;
    // its violation surfaces as a DbUpdateException whose message names the constraint.
    private static bool IsOverlap(DbUpdateException ex)
        => ex.InnerException?.Message.Contains("ex_appointments_no_overlap", StringComparison.OrdinalIgnoreCase) == true;
}
