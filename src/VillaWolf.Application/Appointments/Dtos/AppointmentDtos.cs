using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Appointments.Dtos;

public sealed record AppointmentAddonDto(
    Guid Id,
    Guid ServiceAddonId,
    string Name,
    decimal Price,
    int DurationMinutes);

public sealed record AppointmentDto(
    Guid Id,
    Guid ClientId,
    Guid EmployeeId,
    Guid ServiceId,
    string ServiceName,
    DateTime StartUtc,
    DateTime EndUtc,
    int TotalDurationMinutes,
    decimal TotalPrice,
    AppointmentStatus Status,
    BookingChannel BookingChannel,
    string? InternalNotes,
    decimal? DepositAmount,
    PaymentMethod? PaymentMethod,
    IReadOnlyList<AppointmentAddonDto> Addons);

public sealed record AppointmentListItemDto(
    Guid Id,
    Guid ClientId,
    Guid EmployeeId,
    string ServiceName,
    DateTime StartUtc,
    DateTime EndUtc,
    decimal TotalPrice,
    AppointmentStatus Status);

public sealed record CreateAppointmentRequest(
    Guid ClientId,
    Guid EmployeeId,
    Guid ServiceId,
    DateTime StartUtc,
    List<Guid>? AddonIds,
    BookingChannel BookingChannel,
    string? InternalNotes,
    bool AllowOverbooking = false);

public sealed record RescheduleAppointmentRequest(DateTime NewStartUtc);
