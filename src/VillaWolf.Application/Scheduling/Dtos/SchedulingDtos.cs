using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Scheduling.Dtos;

public sealed record WorkingHourDto(
    Guid Id, Guid? EmployeeId, DayOfWeek DayOfWeek, TimeOnly StartTime, TimeOnly EndTime, bool IsActive);

public sealed record CreateWorkingHourRequest(
    Guid? EmployeeId, DayOfWeek DayOfWeek, TimeOnly StartTime, TimeOnly EndTime);

public sealed record TimeBlockDto(
    Guid Id, Guid? EmployeeId, DateTime StartUtc, DateTime EndUtc, TimeBlockReason Reason, string? Notes);

public sealed record CreateTimeBlockRequest(
    Guid? EmployeeId, DateTime StartUtc, DateTime EndUtc, TimeBlockReason Reason, string? Notes);

public sealed record FreeSlotDto(DateTime StartUtc, DateTime EndUtc, string LocalStart, string LocalEnd);
