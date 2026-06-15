using VillaWolf.Domain.Common;

namespace VillaWolf.Application.Abstractions;

/// <summary>Data needed to create/update an external calendar event for an appointment.</summary>
public sealed record CalendarEventData(
    Guid AppointmentId,
    string Title,
    DateTime StartUtc,
    DateTime EndUtc,
    string? CalendarId,
    string? Description);

/// <summary>
/// Pluggable calendar sync provider. Implementations (Null / mocked Google / future real Google) live
/// in Infrastructure and are selected by configuration, keeping the integration decoupled and
/// swappable/disable-able.
/// </summary>
public interface ICalendarSyncProvider
{
    string Name { get; }
    bool IsEnabled { get; }

    /// <summary>Creates the external event and returns its id.</summary>
    Task<Result<string>> CreateEventAsync(CalendarEventData data, CancellationToken ct = default);

    Task<Result> DeleteEventAsync(string externalEventId, string? calendarId, CancellationToken ct = default);
}
