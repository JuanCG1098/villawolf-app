using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Abstractions;

public sealed record NotificationMessage(
    NotificationChannel Channel,
    NotificationType Type,
    Guid RecipientId,
    string Payload);

/// <summary>
/// Delivers notifications over a channel (WhatsApp/email/push). Implemented in Infrastructure; for the
/// MVP a mock sender records intent without contacting any external service. <see cref="IsLive"/>
/// distinguishes a real send from a mocked one.
/// </summary>
public interface INotificationSender
{
    bool IsLive { get; }
    Task<Result> SendAsync(NotificationMessage message, CancellationToken ct = default);
}
