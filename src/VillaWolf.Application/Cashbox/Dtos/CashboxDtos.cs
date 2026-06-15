using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Cashbox.Dtos;

public sealed record PaymentDto(
    Guid Id,
    Guid? AppointmentId,
    decimal Amount,
    PaymentMethod Method,
    PaymentType Type,
    decimal DiscountAmount,
    string? Notes,
    DateTime CreatedAtUtc);

public sealed record CreatePaymentRequest(
    Guid? AppointmentId,
    decimal Amount,
    PaymentMethod Method,
    PaymentType Type,
    decimal DiscountAmount,
    string? Notes);

public sealed record MethodTotalDto(PaymentMethod Method, decimal Total, int Count);

public sealed record CashboxSummaryDto(
    DateOnly Date,
    decimal Total,
    int Count,
    IReadOnlyList<MethodTotalDto> ByMethod);
