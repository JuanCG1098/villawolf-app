using FluentAssertions;
using VillaWolf.Application.Dashboard;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Tests;

/// <summary>Dashboard summary aggregation (EF InMemory).</summary>
public sealed class DashboardTests
{
    [Fact]
    public async Task Summary_aggregates_today_counts_revenue_and_alerts()
    {
        var db = TestDb.Create();

        var category = new ServiceCategory("Cabello", 1);
        db.ServiceCategories.Add(category);
        var service = new Service("Corte", null, 30, 6000m, category.Id, ServiceTargetAudience.Male, false, true);
        db.Services.Add(service);
        db.Clients.Add(new Client("Martina", "Gómez", null, null, null));
        db.Employees.Add(new Employee(Guid.NewGuid(), "Lucas", "Wolf", null, "#000"));

        var now = DateTime.UtcNow;
        var confirmed = new Appointment(Guid.NewGuid(), Guid.NewGuid(), service, now.AddMinutes(30), BookingChannel.Manual, null);
        confirmed.Confirm();
        var pending = new Appointment(Guid.NewGuid(), Guid.NewGuid(), service, now.AddHours(2), BookingChannel.Manual, null);
        db.Appointments.AddRange(confirmed, pending);

        db.Payments.Add(new Payment(confirmed.Id, 6000m, PaymentMethod.Cash, PaymentType.Payment, 0, null, null));
        db.Products.Add(new Product("Aceite", "Barba", 1, 5, 1000m, null)); // low stock

        await db.SaveChangesAsync();

        var summary = await new DashboardService(db).GetSummaryAsync(null);

        summary.AppointmentsToday.Should().Be(2);
        summary.Confirmed.Should().Be(1);
        summary.Pending.Should().Be(1);
        summary.RevenueToday.Should().Be(6000m);
        summary.ActiveClients.Should().Be(1);
        summary.ActiveEmployees.Should().Be(1);
        summary.ActiveServices.Should().Be(1);
        summary.LowStockProducts.Should().Be(1);
    }
}
