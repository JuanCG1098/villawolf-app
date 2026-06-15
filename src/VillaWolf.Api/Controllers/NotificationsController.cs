using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Notifications;
using VillaWolf.Application.Notifications.Dtos;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize(Roles = "Admin,Reception")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notifications;

    public NotificationsController(INotificationService notifications) => _notifications = notifications;

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] Guid? recipientId, [FromQuery] Guid? appointmentId, [FromQuery] NotificationStatus? status,
        CancellationToken ct)
        => Ok(await _notifications.ListAsync(recipientId, appointmentId, status, ct));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateNotificationRequest request, CancellationToken ct)
        => (await _notifications.CreateAsync(request, ct)).ToActionResult(this);
}
