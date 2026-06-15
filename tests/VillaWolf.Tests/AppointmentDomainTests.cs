using FluentAssertions;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Tests;

/// <summary>Pure domain rules for appointments (no database).</summary>
public sealed class AppointmentDomainTests
{
    private static Service Service(int minutes = 30, decimal price = 6000m) =>
        new("Corte", null, minutes, price, Guid.NewGuid(), ServiceTargetAudience.Male, false, true);

    private static Appointment NewAppointment(Service service) =>
        new(Guid.NewGuid(), Guid.NewGuid(), service, DateTime.UtcNow.AddDays(1), BookingChannel.Manual, null);

    [Fact]
    public void Create_starts_pending_with_computed_end()
    {
        var service = Service(minutes: 30);
        var appointment = NewAppointment(service);

        appointment.Status.Should().Be(AppointmentStatus.Pending);
        appointment.TotalDurationMinutes.Should().Be(30);
        appointment.TotalPrice.Should().Be(6000m);
        appointment.EndUtc.Should().Be(appointment.StartUtc.AddMinutes(30));
    }

    [Fact]
    public void Adding_an_addon_recalculates_total_and_end()
    {
        var appointment = NewAppointment(Service(minutes: 30, price: 6000m));
        appointment.AddAddon(new ServiceAddon("Lavado", 10, 1500m, ServiceTargetAudience.Unisex));

        appointment.TotalDurationMinutes.Should().Be(40);
        appointment.TotalPrice.Should().Be(7500m);
        appointment.EndUtc.Should().Be(appointment.StartUtc.AddMinutes(40));
    }

    [Fact]
    public void Cannot_complete_a_cancelled_appointment()
    {
        var appointment = NewAppointment(Service());
        appointment.Cancel();

        var act = appointment.Complete;
        act.Should().Throw<InvalidOperationException>();
        appointment.Status.Should().Be(AppointmentStatus.Cancelled);
    }

    [Fact]
    public void Snapshot_stays_fixed_when_the_service_changes_afterwards()
    {
        var service = Service(minutes: 30, price: 6000m);
        var appointment = NewAppointment(service);

        // The catalogue changes after booking...
        service.Update("Corte premium", null, 60, 9000m, service.CategoryId,
            ServiceTargetAudience.Male, false, true);

        // ...but the appointment keeps the price/duration captured at booking time.
        appointment.ServicePriceSnapshot.Should().Be(6000m);
        appointment.TotalDurationMinutes.Should().Be(30);
        appointment.TotalPrice.Should().Be(6000m);
    }
}
