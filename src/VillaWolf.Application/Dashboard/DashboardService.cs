using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Dashboard.Dtos;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Dashboard;

public interface IDashboardService
{
    Task<DashboardSummaryDto> GetSummaryAsync(DateOnly? date, CancellationToken ct = default);
}

public sealed class DashboardService : IDashboardService
{
    private readonly IAppDbContext _db;

    public DashboardService(IAppDbContext db) => _db = db;

    public async Task<DashboardSummaryDto> GetSummaryAsync(DateOnly? date, CancellationToken ct = default)
    {
        var day = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var start = new DateTime(day.Year, day.Month, day.Day, 0, 0, 0, DateTimeKind.Utc);
        var end = start.AddDays(1);

        var statuses = await _db.Appointments
            .Where(a => a.StartUtc >= start && a.StartUtc < end)
            .Select(a => a.Status)
            .ToListAsync(ct);

        var payments = await _db.Payments
            .Where(p => p.CreatedAtUtc >= start && p.CreatedAtUtc < end)
            .Select(p => new { p.Amount, p.Type })
            .ToListAsync(ct);
        var revenue = payments.Where(p => p.Type != PaymentType.Refund).Sum(p => p.Amount);

        var products = await _db.Products.Where(p => p.IsActive)
            .Select(p => new { p.CurrentStock, p.MinStock })
            .ToListAsync(ct);

        return new DashboardSummaryDto(
            Date: day,
            AppointmentsToday: statuses.Count,
            Confirmed: statuses.Count(s => s == AppointmentStatus.Confirmed),
            Pending: statuses.Count(s => s == AppointmentStatus.Pending),
            Completed: statuses.Count(s => s == AppointmentStatus.Completed),
            RevenueToday: revenue,
            ActiveClients: await _db.Clients.CountAsync(c => c.IsActive, ct),
            ActiveEmployees: await _db.Employees.CountAsync(e => e.IsActive, ct),
            ActiveServices: await _db.Services.CountAsync(s => s.IsActive, ct),
            LowStockProducts: products.Count(p => p.CurrentStock <= p.MinStock),
            CamerasNeedingAttention: await _db.CameraDevices.CountAsync(
                c => c.Status == CameraStatus.Maintenance || (c.BatteryLevel != null && c.BatteryLevel <= 20), ct));
    }
}
