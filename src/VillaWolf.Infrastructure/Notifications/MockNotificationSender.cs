using VillaWolf.Application.Abstractions;
using VillaWolf.Domain.Common;

namespace VillaWolf.Infrastructure.Notifications;

/// <summary>
/// MVP notification sender: records the intent as successful without contacting any external service
/// (WhatsApp/email/push). Swap for real senders behind <see cref="INotificationSender"/> later.
/// </summary>
public sealed class MockNotificationSender : INotificationSender
{
    public bool IsLive => false;

    public Task<Result> SendAsync(NotificationMessage message, CancellationToken ct = default)
        => Task.FromResult(Result.Success());
}
