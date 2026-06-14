using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A reminder/notification to a client or employee over a channel (WhatsApp/email/push). For the
/// MVP the actual sending is mocked; this entity records intent, scheduling and outcome.
/// </summary>
public class Notification : EntityBase
{
    private Notification() { }

    public Notification(NotificationType type, NotificationChannel channel,
        NotificationRecipientType recipientType, Guid recipientId, Guid? appointmentId,
        DateTime scheduledForUtc, string payload)
    {
        Type = type;
        Channel = channel;
        RecipientType = recipientType;
        RecipientId = recipientId;
        AppointmentId = appointmentId;
        ScheduledForUtc = DateTime.SpecifyKind(scheduledForUtc, DateTimeKind.Utc);
        Payload = payload;
        Status = NotificationStatus.Pending;
    }

    public NotificationType Type { get; private set; }
    public NotificationChannel Channel { get; private set; }
    public NotificationRecipientType RecipientType { get; private set; }
    public Guid RecipientId { get; private set; }
    public Guid? AppointmentId { get; private set; }
    public DateTime ScheduledForUtc { get; private set; }
    public NotificationStatus Status { get; private set; }
    public DateTime? SentAtUtc { get; private set; }
    public string Payload { get; private set; } = null!;

    public void MarkSent() { Status = NotificationStatus.Sent; SentAtUtc = DateTime.UtcNow; Touch(); }
    public void MarkMocked() { Status = NotificationStatus.Mocked; SentAtUtc = DateTime.UtcNow; Touch(); }
    public void MarkFailed() { Status = NotificationStatus.Failed; Touch(); }
}
