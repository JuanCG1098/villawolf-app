using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Cashbox.Dtos;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Cashbox;

public interface ICashboxService
{
    Task<Result<PaymentDto>> RegisterAsync(CreatePaymentRequest request, Guid? registeredByUserId, CancellationToken ct = default);
    Task<IReadOnlyList<PaymentDto>> ListAsync(DateTime? fromUtc, DateTime? toUtc, CancellationToken ct = default);
    Task<CashboxSummaryDto> GetSummaryAsync(DateOnly date, CancellationToken ct = default);
}

public sealed class CashboxService : ICashboxService
{
    private readonly IAppDbContext _db;

    public CashboxService(IAppDbContext db) => _db = db;

    public async Task<Result<PaymentDto>> RegisterAsync(CreatePaymentRequest request, Guid? registeredByUserId, CancellationToken ct = default)
    {
        if (request.AppointmentId is not null &&
            !await _db.Appointments.AnyAsync(a => a.Id == request.AppointmentId, ct))
        {
            return Result.Failure<PaymentDto>(Error.Validation("payment.appointment_invalid", "The appointment does not exist."));
        }

        var payment = new Payment(request.AppointmentId, request.Amount, request.Method, request.Type,
            request.DiscountAmount, registeredByUserId, request.Notes);

        _db.Payments.Add(payment);
        await _db.SaveChangesAsync(ct);
        return payment.ToDto();
    }

    public async Task<IReadOnlyList<PaymentDto>> ListAsync(DateTime? fromUtc, DateTime? toUtc, CancellationToken ct = default)
    {
        var query = _db.Payments.AsQueryable();
        if (fromUtc is not null) query = query.Where(p => p.CreatedAtUtc >= fromUtc);
        if (toUtc is not null) query = query.Where(p => p.CreatedAtUtc < toUtc);

        var payments = await query.OrderByDescending(p => p.CreatedAtUtc).ToListAsync(ct);
        return payments.Select(p => p.ToDto()).ToList();
    }

    public async Task<CashboxSummaryDto> GetSummaryAsync(DateOnly date, CancellationToken ct = default)
    {
        var start = new DateTime(date.Year, date.Month, date.Day, 0, 0, 0, DateTimeKind.Utc);
        var end = start.AddDays(1);

        var rows = await _db.Payments
            .Where(p => p.CreatedAtUtc >= start && p.CreatedAtUtc < end)
            .Select(p => new { p.Method, p.Amount, p.Type })
            .ToListAsync(ct);

        var income = rows.Where(r => r.Type != PaymentType.Refund).ToList();
        var byMethod = income
            .GroupBy(r => r.Method)
            .Select(g => new MethodTotalDto(g.Key, g.Sum(x => x.Amount), g.Count()))
            .OrderBy(m => m.Method)
            .ToList();

        return new CashboxSummaryDto(date, income.Sum(r => r.Amount), rows.Count, byMethod);
    }
}
