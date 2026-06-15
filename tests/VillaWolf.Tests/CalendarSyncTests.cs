using FluentAssertions;
using VillaWolf.Application.Calendar;
using VillaWolf.Application.Calendar.Dtos;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;
using VillaWolf.Infrastructure.Calendar;
using VillaWolf.Infrastructure.Persistence;

namespace VillaWolf.Tests;

/// <summary>Iteration 6: Google Calendar export (mocked provider) and integration links.</summary>
public sealed class CalendarSyncTests
{
    private static async Task<(AppDbContext db, Guid appointmentId)> SeedAppointmentAsync()
    {
        var db = TestDb.Create();
        var category = new ServiceCategory("Cabello", 1);
        db.ServiceCategories.Add(category);
        var service = new Service("Corte", null, 30, 6000m, category.Id, ServiceTargetAudience.Male, false, true);
        db.Services.Add(service);
        var appointment = new Appointment(Guid.NewGuid(), Guid.NewGuid(), service,
            DateTime.UtcNow.AddDays(1), BookingChannel.Manual, null);
        db.Appointments.Add(appointment);
        await db.SaveChangesAsync();
        return (db, appointment.Id);
    }

    [Fact]
    public async Task Export_creates_event_and_is_idempotent()
    {
        var (db, appointmentId) = await SeedAppointmentAsync();
        var calendar = new CalendarService(db, new MockGoogleCalendarSyncProvider());

        var first = await calendar.ExportAppointmentAsync(appointmentId);
        first.IsSuccess.Should().BeTrue();
        first.Value.AlreadySynced.Should().BeFalse();
        first.Value.GoogleEventId.Should().StartWith("gcal_");

        // Second export must not create a duplicate — it returns the same id.
        var second = await calendar.ExportAppointmentAsync(appointmentId);
        second.Value.AlreadySynced.Should().BeTrue();
        second.Value.GoogleEventId.Should().Be(first.Value.GoogleEventId);
    }

    [Fact]
    public async Task Export_with_disabled_provider_fails()
    {
        var (db, appointmentId) = await SeedAppointmentAsync();
        var calendar = new CalendarService(db, new NullCalendarSyncProvider());

        var result = await calendar.ExportAppointmentAsync(appointmentId);

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("calendar.disabled");
    }

    [Fact]
    public async Task Connecting_the_same_owner_twice_reconnects_without_duplicating()
    {
        var db = TestDb.Create();
        var calendar = new CalendarService(db, new MockGoogleCalendarSyncProvider());

        await calendar.ConnectAsync(new ConnectCalendarRequest(CalendarOwnerType.Business, null, "old@group.calendar.google.com"));
        await calendar.ConnectAsync(new ConnectCalendarRequest(CalendarOwnerType.Business, null, "new@group.calendar.google.com"));

        var integrations = await calendar.ListIntegrationsAsync();
        integrations.Should().HaveCount(1);
        integrations.Single().GoogleCalendarId.Should().Be("new@group.calendar.google.com");
    }
}
