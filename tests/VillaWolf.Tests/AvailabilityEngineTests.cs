using FluentAssertions;
using VillaWolf.Application.Appointments;
using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Application.Scheduling;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;
using VillaWolf.Infrastructure.Persistence;

namespace VillaWolf.Tests;

/// <summary>
/// Verifies the Iteration 3 availability engine over an in-memory database: free-slot generation,
/// working-hours / overlap validation, and overbooking. (The DB exclusion constraint and real-Postgres
/// timezone behaviour are covered separately via the Docker end-to-end run.)
/// </summary>
public sealed class AvailabilityEngineTests
{
    private const string TimeZoneId = "America/Argentina/Buenos_Aires";
    private static readonly TimeZoneInfo Tz = TimeZoneInfo.FindSystemTimeZoneById(TimeZoneId);
    private static readonly DateOnly Date = new(2026, 7, 6); // a working weekday in the seed

    private static DateTime Utc(int hour, int minute = 0)
        => TimeZoneInfo.ConvertTimeToUtc(Date.ToDateTime(new TimeOnly(hour, minute)), Tz);

    private static async Task<Seed> SeedAsync()
    {
        var db = TestDb.Create();

        db.BusinessSettings.Add(new BusinessSettings("VILLAWOLF — hair studio", TimeZoneId, "ARS", 30));

        var employee = new Employee(Guid.NewGuid(), "Lucas", "Wolf", null, "#C8A24B");
        db.Employees.Add(employee);

        // Business-wide hours for the test date: 09:00–18:00.
        db.WorkingHours.Add(new WorkingHour(null, Date.DayOfWeek, new TimeOnly(9, 0), new TimeOnly(18, 0)));

        var category = new ServiceCategory("Cabello", 1);
        db.ServiceCategories.Add(category);
        var service = new Service("Corte", null, 30, 6000m, category.Id, ServiceTargetAudience.Male, false, true);
        db.Services.Add(service);
        var addon = new ServiceAddon("Lavado", 10, 1500m, ServiceTargetAudience.Unisex);
        db.ServiceAddons.Add(addon);

        var client = new Client("Martina", "Gomez", null, null, null);
        db.Clients.Add(client);

        await db.SaveChangesAsync();
        return new Seed(db, employee.Id, service.Id, addon.Id, client.Id);
    }

    private sealed record Seed(AppDbContext Db, Guid EmployeeId, Guid ServiceId, Guid AddonId, Guid ClientId)
    {
        public SchedulingService Scheduling => new(Db);
        public AppointmentService Appointments => new(Db, Scheduling);

        public CreateAppointmentRequest Request(DateTime startUtc, List<Guid>? addons = null)
            => new(ClientId, EmployeeId, ServiceId, startUtc, addons, BookingChannel.Manual, null);
    }

    [Fact]
    public async Task FreeSlots_within_working_hours_returns_every_slot()
    {
        var seed = await SeedAsync();

        var result = await seed.Scheduling.GetFreeSlotsAsync(seed.EmployeeId, Date, seed.ServiceId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().HaveCount(18); // 09:00..17:30 in 30-min steps
        result.Value.First().LocalStart.Should().Be("09:00");
        result.Value.Last().LocalStart.Should().Be("17:30");
    }

    [Fact]
    public async Task FreeSlots_excludes_a_slot_once_it_is_booked()
    {
        var seed = await SeedAsync();
        (await seed.Appointments.CreateAsync(seed.Request(Utc(10)), allowOverbooking: false)).IsSuccess.Should().BeTrue();

        var result = await seed.Scheduling.GetFreeSlotsAsync(seed.EmployeeId, Date, seed.ServiceId);

        result.Value.Select(s => s.LocalStart).Should().NotContain("10:00");
    }

    [Fact]
    public async Task EnsureAvailable_succeeds_inside_hours_and_fails_outside()
    {
        var seed = await SeedAsync();

        (await seed.Scheduling.EnsureAvailableAsync(seed.EmployeeId, Utc(10), 30)).IsSuccess.Should().BeTrue();

        var outside = await seed.Scheduling.EnsureAvailableAsync(seed.EmployeeId, Utc(7), 30);
        outside.IsFailure.Should().BeTrue();
        outside.Error.Code.Should().Be("availability.outside_hours");
    }

    [Fact]
    public async Task Booking_computes_totals_from_service_and_addons()
    {
        var seed = await SeedAsync();

        var result = await seed.Appointments.CreateAsync(
            seed.Request(Utc(11), addons: [seed.AddonId]), allowOverbooking: false);

        result.IsSuccess.Should().BeTrue();
        result.Value.TotalDurationMinutes.Should().Be(40);   // 30 + 10
        result.Value.TotalPrice.Should().Be(7500m);          // 6000 + 1500
        result.Value.EndUtc.Should().Be(result.Value.StartUtc.AddMinutes(40));
    }

    [Fact]
    public async Task Booking_outside_working_hours_is_rejected()
    {
        var seed = await SeedAsync();

        var result = await seed.Appointments.CreateAsync(seed.Request(Utc(7)), allowOverbooking: false);

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("availability.outside_hours");
    }

    [Fact]
    public async Task Overlapping_booking_is_rejected_unless_overbooking()
    {
        var seed = await SeedAsync();
        (await seed.Appointments.CreateAsync(seed.Request(Utc(10)), allowOverbooking: false)).IsSuccess.Should().BeTrue();

        // 10:15 overlaps the 10:00–10:30 appointment.
        var overlap = seed.Request(Utc(10, 15));

        var rejected = await seed.Appointments.CreateAsync(overlap, allowOverbooking: false);
        rejected.IsFailure.Should().BeTrue();
        rejected.Error.Code.Should().Be("appointment.overlap");

        var overbooked = await seed.Appointments.CreateAsync(overlap, allowOverbooking: true);
        overbooked.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task FreeSlots_on_a_non_working_day_is_empty()
    {
        var seed = await SeedAsync();
        // Only Date's day-of-week has hours seeded, so the next day has none.
        var nonWorkingDay = Date.AddDays(1);

        var result = await seed.Scheduling.GetFreeSlotsAsync(seed.EmployeeId, nonWorkingDay, seed.ServiceId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeEmpty();
    }
}
