using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A retail/consumable product (wax, shampoo, blades, towels...). Stock is adjusted through
/// <see cref="InventoryMovement"/>s; <see cref="IsLowStock"/> drives the dashboard alert.
/// </summary>
public class Product : EntityBase
{
    private Product() { }

    public Product(string name, string category, int currentStock, int minStock,
        decimal purchasePrice, decimal? salePrice)
    {
        if (currentStock < 0) throw new ArgumentException("Stock cannot be negative.", nameof(currentStock));
        if (minStock < 0) throw new ArgumentException("Minimum stock cannot be negative.", nameof(minStock));

        Name = name;
        Category = category;
        CurrentStock = currentStock;
        MinStock = minStock;
        PurchasePrice = purchasePrice;
        SalePrice = salePrice;
        IsActive = true;
    }

    public string Name { get; private set; } = null!;
    public string Category { get; private set; } = null!;
    public int CurrentStock { get; private set; }
    public int MinStock { get; private set; }
    public decimal PurchasePrice { get; private set; }
    public decimal? SalePrice { get; private set; }
    public bool IsActive { get; private set; } = true;

    public bool IsLowStock => CurrentStock <= MinStock;

    public void Update(string name, string category, int minStock, decimal purchasePrice, decimal? salePrice)
    {
        Name = name;
        Category = category;
        MinStock = minStock < 0 ? MinStock : minStock;
        PurchasePrice = purchasePrice;
        SalePrice = salePrice;
        Touch();
    }

    /// <summary>Applies a signed change to the stock, refusing to go below zero.</summary>
    public void AdjustStock(int delta)
    {
        var next = CurrentStock + delta;
        if (next < 0) throw new InvalidOperationException("Resulting stock cannot be negative.");
        CurrentStock = next;
        Touch();
    }

    public void Activate() { IsActive = true; Touch(); }
    public void Deactivate() { IsActive = false; Touch(); }
}
