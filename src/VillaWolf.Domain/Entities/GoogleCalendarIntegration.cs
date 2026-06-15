using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A link between the system and a Google Calendar — either the shop's general calendar or an
/// individual employee's. Tokens are stored encrypted by the infrastructure layer. The actual sync
/// runs behind an interface so it can be swapped or disabled.
/// </summary>
public class GoogleCalendarIntegration : EntityBase
{
    private GoogleCalendarIntegration() { }

    public GoogleCalendarIntegration(CalendarOwnerType ownerType, Guid? employeeId, string googleCalendarId)
    {
        if (ownerType == CalendarOwnerType.Employee && employeeId is null)
            throw new ArgumentException("An employee calendar requires an employee id.", nameof(employeeId));

        OwnerType = ownerType;
        EmployeeId = employeeId;
        GoogleCalendarId = googleCalendarId;
        SyncEnabled = true;
    }

    public CalendarOwnerType OwnerType { get; private set; }
    public Guid? EmployeeId { get; private set; }
    public string GoogleCalendarId { get; private set; } = null!;
    public string? AccessToken { get; private set; }
    public string? RefreshToken { get; private set; }
    public DateTime? TokenExpiryUtc { get; private set; }
    public bool SyncEnabled { get; private set; }
    public DateTime? LastSyncUtc { get; private set; }

    public void UpdateTokens(string accessToken, string refreshToken, DateTime expiryUtc)
    {
        AccessToken = accessToken;
        RefreshToken = refreshToken;
        TokenExpiryUtc = DateTime.SpecifyKind(expiryUtc, DateTimeKind.Utc);
        Touch();
    }

    public void SetSyncEnabled(bool enabled) { SyncEnabled = enabled; Touch(); }
    public void MarkSynced() { LastSyncUtc = DateTime.UtcNow; Touch(); }

    /// <summary>Re-point this link to a calendar id and re-enable sync.</summary>
    public void Reconnect(string googleCalendarId)
    {
        GoogleCalendarId = googleCalendarId;
        SyncEnabled = true;
        Touch();
    }
}
