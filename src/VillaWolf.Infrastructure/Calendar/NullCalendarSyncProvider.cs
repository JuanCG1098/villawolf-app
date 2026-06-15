using VillaWolf.Application.Abstractions;
using VillaWolf.Domain.Common;

namespace VillaWolf.Infrastructure.Calendar;

/// <summary>Calendar sync turned off — every export reports the feature as disabled.</summary>
public sealed class NullCalendarSyncProvider : ICalendarSyncProvider
{
    public string Name => "None";
    public bool IsEnabled => false;

    public Task<Result<string>> CreateEventAsync(CalendarEventData data, CancellationToken ct = default)
        => Task.FromResult(Result.Failure<string>(Error.Conflict("calendar.disabled", "Calendar sync is disabled.")));

    public Task<Result> DeleteEventAsync(string externalEventId, string? calendarId, CancellationToken ct = default)
        => Task.FromResult(Result.Success());
}
