using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Calendar.Dtos;

public sealed record CalendarIntegrationDto(
    Guid Id,
    CalendarOwnerType OwnerType,
    Guid? EmployeeId,
    string GoogleCalendarId,
    bool SyncEnabled,
    DateTime? LastSyncUtc);

public sealed record ConnectCalendarRequest(
    CalendarOwnerType OwnerType,
    Guid? EmployeeId,
    string GoogleCalendarId);

public sealed record AppointmentSyncResultDto(Guid AppointmentId, string GoogleEventId, bool AlreadySynced);
