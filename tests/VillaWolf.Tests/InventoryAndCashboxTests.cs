using FluentAssertions;
using VillaWolf.Application.Cashbox;
using VillaWolf.Application.Cashbox.Dtos;
using VillaWolf.Application.Inventory;
using VillaWolf.Application.Inventory.Dtos;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Tests;

/// <summary>Iteration 5: inventory stock movements and cash-box daily totals (EF InMemory).</summary>
public sealed class InventoryAndCashboxTests
{
    [Fact]
    public async Task Sale_movement_reduces_stock()
    {
        var db = TestDb.Create();
        var product = new Product("Cera", "Styling", 10, 2, 1000m, 2000m);
        db.Products.Add(product);
        await db.SaveChangesAsync();
        var inventory = new InventoryService(db);

        var result = await inventory.RegisterMovementAsync(
            new CreateMovementRequest(product.Id, InventoryMovementType.Sale, 3, null, null, 2000m, null));

        result.IsSuccess.Should().BeTrue();
        result.Value.StockDelta.Should().Be(-3);
        (await inventory.GetProductAsync(product.Id)).Value.CurrentStock.Should().Be(7);
    }

    [Fact]
    public async Task Purchase_movement_increases_stock()
    {
        var db = TestDb.Create();
        var product = new Product("Shampoo", "Cuidado", 5, 2, 1000m, null);
        db.Products.Add(product);
        await db.SaveChangesAsync();
        var inventory = new InventoryService(db);

        await inventory.RegisterMovementAsync(
            new CreateMovementRequest(product.Id, InventoryMovementType.Purchase, 8, null, null, null, null));

        (await inventory.GetProductAsync(product.Id)).Value.CurrentStock.Should().Be(13);
    }

    [Fact]
    public async Task Sale_beyond_stock_is_rejected_and_stock_unchanged()
    {
        var db = TestDb.Create();
        var product = new Product("Aceite", "Barba", 4, 2, 1000m, null);
        db.Products.Add(product);
        await db.SaveChangesAsync();
        var inventory = new InventoryService(db);

        var result = await inventory.RegisterMovementAsync(
            new CreateMovementRequest(product.Id, InventoryMovementType.Sale, 10, null, null, null, null));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("inventory.insufficient_stock");
        (await inventory.GetProductAsync(product.Id)).Value.CurrentStock.Should().Be(4);
    }

    [Fact]
    public async Task Cashbox_summary_totals_by_method()
    {
        var db = TestDb.Create();
        var cashbox = new CashboxService(db);
        await cashbox.RegisterAsync(new CreatePaymentRequest(null, 6000m, PaymentMethod.Cash, PaymentType.Payment, 0, null), null);
        await cashbox.RegisterAsync(new CreatePaymentRequest(null, 9000m, PaymentMethod.Card, PaymentType.Payment, 0, null), null);
        await cashbox.RegisterAsync(new CreatePaymentRequest(null, 1000m, PaymentMethod.Cash, PaymentType.Tip, 0, null), null);

        var summary = await cashbox.GetSummaryAsync(DateOnly.FromDateTime(DateTime.UtcNow));

        summary.Count.Should().Be(3);
        summary.Total.Should().Be(16000m);
        summary.ByMethod.Single(m => m.Method == PaymentMethod.Cash).Total.Should().Be(7000m);
        summary.ByMethod.Single(m => m.Method == PaymentMethod.Card).Total.Should().Be(9000m);
    }
}
