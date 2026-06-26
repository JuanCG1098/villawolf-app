namespace VillaWolf.Application.Dashboard.Dtos;

public sealed record DashboardSummaryDto(
    DateOnly Date,
    int AppointmentsToday,
    int Confirmed,
    int Pending,
    int Completed,
    decimal RevenueToday,
    int ActiveClients,
    int ActiveEmployees,
    int ActiveServices,
    int LowStockProducts);
