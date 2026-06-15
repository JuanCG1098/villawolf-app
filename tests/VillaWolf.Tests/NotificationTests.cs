using FluentAssertions;
using VillaWolf.Application.Notifications;
using VillaWolf.Application.Notifications.Dtos;
using VillaWolf.Domain.Enums;
using VillaWolf.Infrastructure.Notifications;

namespace VillaWolf.Tests;

/// <summary>Notifications module with the mock sender (EF InMemory).</summary>
public sealed class NotificationTests
{
    [Fact]
    public async Task Creating_a_notification_records_it_as_mocked()
    {
        var db = TestDb.Create();
        var service = new NotificationService(db, new MockNotificationSender());

        var result = await service.CreateAsync(new CreateNotificationRequest(
            NotificationType.Reminder,
            NotificationChannel.WhatsApp,
            NotificationRecipientType.Client,
            Guid.NewGuid(),
            null,
            null,
            "Recordatorio: tu turno es mañana a las 15:00."));

        result.IsSuccess.Should().BeTrue();
        result.Value.Status.Should().Be(NotificationStatus.Mocked);
        result.Value.Payload.Should().Contain("Recordatorio");

        var all = await service.ListAsync(null, null, null);
        all.Should().HaveCount(1);
    }
}
