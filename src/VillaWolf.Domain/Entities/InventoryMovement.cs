using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A stock movement for a product. Quantity is signed by convention via <see cref="Type"/>
/// (purchases/adjustments add, sales/consumption subtract). Can be linked to the appointment or
/// client it originated from.
/// </summary>
public class InventoryMovement : EntityBase
{
    private InventoryMovement() { }

    public InventoryMovement(Guid productId, InventoryMovementType type, int quantity,
        Guid? appointmentId, Guid? clientId, decimal? unitPrice, string? notes)
    {
        if (quantity <= 0) throw new ArgumentException("Quantity must be positive.", nameof(quantity));

        ProductId = productId;
        Type = type;
        Quantity = quantity;
        AppointmentId = appointmentId;
        ClientId = clientId;
        UnitPrice = unitPrice;
        Notes = notes;
    }

    public Guid ProductId { get; private set; }
    public InventoryMovementType Type { get; private set; }
    public int Quantity { get; private set; }
    public Guid? AppointmentId { get; private set; }
    public Guid? ClientId { get; private set; }
    public decimal? UnitPrice { get; private set; }
    public string? Notes { get; private set; }

    /// <summary>Signed effect on stock (+ for purchase/adjustment, - for sale/consumption).</summary>
    public int StockDelta => Type is InventoryMovementType.Purchase or InventoryMovementType.Adjustment
        ? Quantity
        : -Quantity;
}
