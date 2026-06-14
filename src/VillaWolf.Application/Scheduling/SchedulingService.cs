using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Application.Scheduling.Dtos;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Scheduling;

public sealed class SchedulingService : ISchedulingService
{
    private readonly IAppDbContext _db;

    public SchedulingService(IAppDbContext db) => _db = db;

    // ---------- Working hours ----------

    public async Task<IReadOnlyList<WorkingHourDto>> ListWorkingHoursAsync(Guid? employeeId, CancellationToken ct = default)
    {
        var query = employeeId is null
            ? _db.WorkingHours.Where(w => w.EmployeeId == null)
            : _db.WorkingHours.Where(w => w.EmployeeId == employeeId);

        var hours = await query.OrderBy(w => w.DayOfWeek).ThenBy(w => w.StartTime).ToListAsync(ct);
        return hours.Select(h => h.ToDto()).ToList();
    }

    public async Task<Result<WorkingHourDto>> CreateWorkingHourAsync(CreateWorkingHourRequest request, CancellationToken ct = default)
    {
        if (request.EndTime <= request.StartTime)
            return Result.Failure<WorkingHourDto>(Error.Validation("working_hour.invalid_range", "End time must be after start time."));

        if (request.EmployeeId is not null && !await _db.Employees.AnyAsync(e => e.Id == request.EmployeeId, ct))
            return Result.Failure<WorkingHourDto>(Error.Validation("working_hour.employee_invalid", "The employee does not exist."));

        var workingHour = new WorkingHour(request.EmployeeId, request.DayOfWeek, request.StartTime, request.EndTime);
        _db.WorkingHours.Add(workingHour);
        await _db.SaveChangesAsync(ct);
        return workingHour.ToDto();
    }

    public async Task<Result> DeleteWorkingHourAsync(Guid id, CancellationToken ct = default)
    {
        var workingHour = await _db.WorkingHours.FirstOrDefaultAsync(w => w.Id == id, ct);
        if (workingHour is null) return Result.Failure(Error.NotFound("working_hour.not_found", "Working hour not found."));
        _db.WorkingHours.Remove(workingHour);
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    // ---------- Time blocks ----------

    public async Task<IReadOnlyList<TimeBlockDto>> ListTimeBlocksAsync(Guid? employeeId, DateTime? fromUtc, DateTime? toUtc, CancellationToken ct = default)
    {
        var query = _db.TimeBlocks.AsQueryable();
        if (employeeId is not null) query = query.Where(b => b.EmployeeId == employeeId || b.EmployeeId == null);
        if (fromUtc is not null) query = query.Where(b => b.EndUtc > fromUtc);
        if (toUtc is not null) query = query.Where(b => b.StartUtc < toUtc);

        var blocks = await query.OrderBy(b => b.StartUtc).ToListAsync(ct);
        return blocks.Select(b => b.ToDto()).ToList();
    }

    public async Task<Result<TimeBlockDto>> CreateTimeBlockAsync(CreateTimeBlockRequest request, CancellationToken ct = default)
    {
        if (request.EndUtc <= request.StartUtc)
            return Result.Failure<TimeBlockDto>(Error.Validation("time_block.invalid_range", "End must be after start."));

        if (request.EmployeeId is not null && !await _db.Employees.AnyAsync(e => e.Id == request.EmployeeId, ct))
            return Result.Failure<TimeBlockDto>(Error.Validation("time_block.employee_invalid", "The employee does not exist."));

        var block = new TimeBlock(request.EmployeeId, request.StartUtc, request.EndUtc, request.Reason, request.Notes);
        _db.TimeBlocks.Add(block);
        await _db.SaveChangesAsync(ct);
        return block.ToDto();
    }

    public async Task<Result> DeleteTimeBlockAsync(Guid id, CancellationToken ct = default)
    {
        var block = await _db.TimeBlocks.FirstOrDefaultAsync(b => b.Id == id, ct);
        if (block is null) return Result.Failure(Error.NotFound("time_block.not_found", "Time block not found."));
        _db.TimeBlocks.Remove(block);
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    // ---------- Availability ----------

    public async Task<Result<IReadOnlyList<FreeSlotDto>>> GetFreeSlotsAsync(Guid employeeId, DateOnly date, Guid? serviceId, CancellationToken ct = default)
    {
        if (!await _db.Employees.AnyAsync(e => e.Id == employeeId && e.IsActive, ct))
            return Result.Failure<IReadOnlyList<FreeSlotDto>>(Error.NotFound("employee.not_found", "Employee not found."));

        var (tz, slot) = await GetSettingsAsync(ct);

        var duration = slot;
        if (serviceId is not null)
        {
            var service = await _db.Services.FirstOrDefaultAsync(s => s.Id == serviceId, ct);
            if (service is null)
                return Result.Failure<IReadOnlyList<FreeSlotDto>>(Error.Validation("service.not_found", "The service does not exist."));
            duration = service.DurationMinutes;
        }

        var windows = await GetWindowsAsync(employeeId, date.DayOfWeek, ct);
        if (windows.Count == 0)
            return Result.Success<IReadOnlyList<FreeSlotDto>>(new List<FreeSlotDto>());

        var dayStartUtc = ToUtc(date.ToDateTime(TimeOnly.MinValue), tz);
        var dayEndUtc = dayStartUtc.AddDays(1);

        var appointments = await _db.Appointments
            .Where(a => a.EmployeeId == employeeId && !a.IsOverbooking
                && a.Status != AppointmentStatus.Cancelled && a.Status != AppointmentStatus.NoShow
                && a.StartUtc < dayEndUtc && a.EndUtc > dayStartUtc)
            .Select(a => new { a.StartUtc, a.EndUtc })
            .ToListAsync(ct);

        var blocks = await _db.TimeBlocks
            .Where(b => (b.EmployeeId == employeeId || b.EmployeeId == null)
                && b.StartUtc < dayEndUtc && b.EndUtc > dayStartUtc)
            .Select(b => new { b.StartUtc, b.EndUtc })
            .ToListAsync(ct);

        var slots = new List<FreeSlotDto>();
        foreach (var (start, end) in windows)
        {
            var windowEnd = date.ToDateTime(end);
            for (var cursor = date.ToDateTime(start); cursor.AddMinutes(duration) <= windowEnd; cursor = cursor.AddMinutes(slot))
            {
                var startUtc = ToUtc(cursor, tz);
                var endUtc = startUtc.AddMinutes(duration);

                var free = !appointments.Any(a => a.StartUtc < endUtc && startUtc < a.EndUtc)
                           && !blocks.Any(b => b.StartUtc < endUtc && startUtc < b.EndUtc);

                if (free)
                    slots.Add(new FreeSlotDto(startUtc, endUtc,
                        cursor.ToString("HH:mm"), cursor.AddMinutes(duration).ToString("HH:mm")));
            }
        }

        return Result.Success<IReadOnlyList<FreeSlotDto>>(slots);
    }

    public async Task<Result> EnsureAvailableAsync(Guid employeeId, DateTime startUtc, int durationMinutes,
        Guid? excludeAppointmentId = null, CancellationToken ct = default)
    {
        var (tz, _) = await GetSettingsAsync(ct);
        startUtc = DateTime.SpecifyKind(startUtc, DateTimeKind.Utc);
        var endUtc = startUtc.AddMinutes(durationMinutes);

        var localStart = TimeZoneInfo.ConvertTimeFromUtc(startUtc, tz);
        var localEnd = localStart.AddMinutes(durationMinutes);

        var windows = await GetWindowsAsync(employeeId, localStart.DayOfWeek, ct);
        var startTime = TimeOnly.FromDateTime(localStart);
        var endTime = TimeOnly.FromDateTime(localEnd);

        var insideHours = localStart.Date == localEnd.Date && windows.Any(w => startTime >= w.start && endTime <= w.end);
        if (!insideHours)
            return Result.Failure(Error.Validation("availability.outside_hours", "The requested time is outside working hours."));

        var blocked = await _db.TimeBlocks.AnyAsync(b => (b.EmployeeId == employeeId || b.EmployeeId == null)
            && b.StartUtc < endUtc && b.EndUtc > startUtc, ct);
        if (blocked)
            return Result.Failure(Error.Conflict("availability.blocked", "The requested time is blocked."));

        var overlap = await _db.Appointments.AnyAsync(a => a.EmployeeId == employeeId && !a.IsOverbooking
            && a.Status != AppointmentStatus.Cancelled && a.Status != AppointmentStatus.NoShow
            && (excludeAppointmentId == null || a.Id != excludeAppointmentId)
            && a.StartUtc < endUtc && a.EndUtc > startUtc, ct);
        if (overlap)
            return Result.Failure(Error.Conflict("appointment.overlap", "The employee already has an appointment in that time range."));

        return Result.Success();
    }

    private static DateTime ToUtc(DateTime localUnspecified, TimeZoneInfo tz)
        => TimeZoneInfo.ConvertTimeToUtc(DateTime.SpecifyKind(localUnspecified, DateTimeKind.Unspecified), tz);

    private async Task<(TimeZoneInfo tz, int slot)> GetSettingsAsync(CancellationToken ct)
    {
        var settings = await _db.BusinessSettings.AsNoTracking().FirstOrDefaultAsync(ct);
        var tz = TimeZoneInfo.Utc;
        if (settings is not null)
        {
            try { tz = TimeZoneInfo.FindSystemTimeZoneById(settings.TimeZoneId); }
            catch (TimeZoneNotFoundException) { /* fall back to UTC */ }
            catch (InvalidTimeZoneException) { /* fall back to UTC */ }
        }

        return (tz, settings?.MinSlotMinutes ?? 30);
    }

    private async Task<List<(TimeOnly start, TimeOnly end)>> GetWindowsAsync(Guid employeeId, DayOfWeek day, CancellationToken ct)
    {
        var employeeHours = await _db.WorkingHours
            .Where(w => w.EmployeeId == employeeId && w.DayOfWeek == day && w.IsActive)
            .Select(w => new { w.StartTime, w.EndTime })
            .ToListAsync(ct);

        var source = employeeHours.Count > 0
            ? employeeHours
            : await _db.WorkingHours
                .Where(w => w.EmployeeId == null && w.DayOfWeek == day && w.IsActive)
                .Select(w => new { w.StartTime, w.EndTime })
                .ToListAsync(ct);

        return source.Select(h => (start: h.StartTime, end: h.EndTime)).OrderBy(h => h.start).ToList();
    }
}
