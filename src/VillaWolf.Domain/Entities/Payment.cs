using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A cash-box entry. Usually tied to an appointment, but a null <see cref="AppointmentId"/> covers
/// stand-alone product sales. <see cref="PaymentType"/> distinguishes full payments, deposits, tips
/// and refunds.
/// </summary>
public class Payment : EntityBase
{
    private Payment() { }

    public Payment(Guid? appointmentId, decimal amount, PaymentMethod method, PaymentType type,
        decimal discountAmount, Guid? registeredByUserId, string? notes)
    {
        if (amount < 0) throw new ArgumentException("Amount cannot be negative.", nameof(amount));
        if (discountAmount < 0) throw new ArgumentException("Discount cannot be negative.", nameof(discountAmount));

        AppointmentId = appointmentId;
        Amount = amount;
        Method = method;
        Type = type;
        DiscountAmount = discountAmount;
        RegisteredByUserId = registeredByUserId;
        Notes = notes;
    }

    public Guid? AppointmentId { get; private set; }
    public decimal Amount { get; private set; }
    public PaymentMethod Method { get; private set; }
    public PaymentType Type { get; private set; }
    public decimal DiscountAmount { get; private set; }
    public Guid? RegisteredByUserId { get; private set; }
    public string? Notes { get; private set; }
}
