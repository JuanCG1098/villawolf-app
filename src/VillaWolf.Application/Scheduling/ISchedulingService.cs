using VillaWolf.Application.Scheduling.Dtos;
using VillaWolf.Domain.Common;

namespace VillaWolf.Application.Scheduling;

public interface ISchedulingService
{
    // Working hours
    Task<IReadOnlyList<WorkingHourDto>> ListWorkingHoursAsync(Guid? employeeId, CancellationToken ct = default);
    Task<Result<WorkingHourDto>> CreateWorkingHourAsync(CreateWorkingHourRequest request, CancellationToken ct = default);
    Task<Result> DeleteWorkingHourAsync(Guid id, CancellationToken ct = default);

    // Time blocks
    Task<IReadOnlyList<TimeBlockDto>> ListTimeBlocksAsync(Guid? employeeId, DateTime? fromUtc, DateTime? toUtc, CancellationToken ct = default);
    Task<Result<TimeBlockDto>> CreateTimeBlockAsync(CreateTimeBlockRequest request, CancellationToken ct = default);
    Task<Result> DeleteTimeBlockAsync(Guid id, CancellationToken ct = default);

    // Availability
    Task<Result<IReadOnlyList<FreeSlotDto>>> GetFreeSlotsAsync(Guid employeeId, DateOnly date, Guid? serviceId, CancellationToken ct = default);

    /// <summary>
    /// Validates that [startUtc, startUtc+duration) fits the employee's working hours, hits no time
    /// block, and does not overlap another active appointment. <paramref name="excludeAppointmentId"/>
    /// skips a specific appointment (used when rescheduling).
    /// </summary>
    Task<Result> EnsureAvailableAsync(Guid employeeId, DateTime startUtc, int durationMinutes,
        Guid? excludeAppointmentId = null, CancellationToken ct = default);
}
