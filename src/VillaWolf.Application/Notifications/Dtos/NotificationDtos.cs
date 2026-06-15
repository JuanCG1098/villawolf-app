using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Notifications.Dtos;

public sealed record NotificationDto(
    Guid Id,
    NotificationType Type,
    NotificationChannel Channel,
    NotificationRecipientType RecipientType,
    Guid RecipientId,
    Guid? AppointmentId,
    DateTime ScheduledForUtc,
    NotificationStatus Status,
    DateTime? SentAtUtc,
    string Payload);

public sealed record CreateNotificationRequest(
    NotificationType Type,
    NotificationChannel Channel,
    NotificationRecipientType RecipientType,
    Guid RecipientId,
    Guid? AppointmentId,
    DateTime? ScheduledForUtc,
    string Payload);
