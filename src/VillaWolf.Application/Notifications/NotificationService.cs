using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Application.Notifications.Dtos;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Notifications;

public interface INotificationService
{
    Task<IReadOnlyList<NotificationDto>> ListAsync(Guid? recipientId, Guid? appointmentId, NotificationStatus? status, CancellationToken ct = default);
    Task<Result<NotificationDto>> CreateAsync(CreateNotificationRequest request, CancellationToken ct = default);
}

/// <summary>
/// Records and dispatches notifications. Dispatch is delegated to <see cref="INotificationSender"/>
/// (mocked for the MVP); the outcome is reflected on the notification's status (Mocked/Sent/Failed).
/// </summary>
public sealed class NotificationService : INotificationService
{
    private readonly IAppDbContext _db;
    private readonly INotificationSender _sender;

    public NotificationService(IAppDbContext db, INotificationSender sender)
    {
        _db = db;
        _sender = sender;
    }

    public async Task<IReadOnlyList<NotificationDto>> ListAsync(
        Guid? recipientId, Guid? appointmentId, NotificationStatus? status, CancellationToken ct = default)
    {
        var query = _db.Notifications.AsQueryable();
        if (recipientId is not null) query = query.Where(n => n.RecipientId == recipientId);
        if (appointmentId is not null) query = query.Where(n => n.AppointmentId == appointmentId);
        if (status is not null) query = query.Where(n => n.Status == status);

        var notifications = await query.OrderByDescending(n => n.ScheduledForUtc).ToListAsync(ct);
        return notifications.Select(n => n.ToDto()).ToList();
    }

    public async Task<Result<NotificationDto>> CreateAsync(CreateNotificationRequest request, CancellationToken ct = default)
    {
        var notification = new Notification(
            request.Type, request.Channel, request.RecipientType, request.RecipientId,
            request.AppointmentId, request.ScheduledForUtc ?? DateTime.UtcNow, request.Payload);

        _db.Notifications.Add(notification);

        var result = await _sender.SendAsync(
            new NotificationMessage(request.Channel, request.Type, request.RecipientId, request.Payload), ct);

        if (result.IsFailure) notification.MarkFailed();
        else if (_sender.IsLive) notification.MarkSent();
        else notification.MarkMocked();

        await _db.SaveChangesAsync(ct);
        return notification.ToDto();
    }
}
