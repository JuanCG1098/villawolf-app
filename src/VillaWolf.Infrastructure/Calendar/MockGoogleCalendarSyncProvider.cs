using VillaWolf.Application.Abstractions;
using VillaWolf.Domain.Common;

namespace VillaWolf.Infrastructure.Calendar;

/// <summary>
/// Stand-in for the real Google Calendar API: returns a synthetic event id instead of calling Google.
/// Lets the whole export flow (and the GoogleEventId round-trip) work end-to-end without OAuth, and
/// can be swapped for a real implementation behind <see cref="ICalendarSyncProvider"/> later.
/// </summary>
public sealed class MockGoogleCalendarSyncProvider : ICalendarSyncProvider
{
    public string Name => "MockGoogle";
    public bool IsEnabled => true;

    public Task<Result<string>> CreateEventAsync(CalendarEventData data, CancellationToken ct = default)
        => Task.FromResult(Result.Success($"gcal_{Guid.NewGuid():N}"));

    public Task<Result> DeleteEventAsync(string externalEventId, string? calendarId, CancellationToken ct = default)
        => Task.FromResult(Result.Success());
}
