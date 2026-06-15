using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Application.Inventory.Dtos;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;

namespace VillaWolf.Application.Inventory;

public interface IInventoryService
{
    Task<IReadOnlyList<ProductDto>> ListProductsAsync(bool includeInactive, bool lowStockOnly, CancellationToken ct = default);
    Task<Result<ProductDto>> GetProductAsync(Guid id, CancellationToken ct = default);
    Task<Result<ProductDto>> CreateProductAsync(CreateProductRequest request, CancellationToken ct = default);
    Task<Result<ProductDto>> UpdateProductAsync(Guid id, UpdateProductRequest request, CancellationToken ct = default);
    Task<Result> SetProductActiveAsync(Guid id, bool active, CancellationToken ct = default);
    Task<IReadOnlyList<InventoryMovementDto>> ListMovementsAsync(Guid productId, CancellationToken ct = default);
    Task<Result<InventoryMovementDto>> RegisterMovementAsync(CreateMovementRequest request, CancellationToken ct = default);
}

public sealed class InventoryService : IInventoryService
{
    private readonly IAppDbContext _db;

    public InventoryService(IAppDbContext db) => _db = db;

    public async Task<IReadOnlyList<ProductDto>> ListProductsAsync(bool includeInactive, bool lowStockOnly, CancellationToken ct = default)
    {
        var query = _db.Products.AsQueryable();
        if (!includeInactive) query = query.Where(p => p.IsActive);
        var products = await query.OrderBy(p => p.Name).ToListAsync(ct);
        var result = products.Select(p => p.ToDto());
        if (lowStockOnly) result = result.Where(p => p.IsLowStock);
        return result.ToList();
    }

    public async Task<Result<ProductDto>> GetProductAsync(Guid id, CancellationToken ct = default)
    {
        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == id, ct);
        return product is null
            ? Result.Failure<ProductDto>(Error.NotFound("product.not_found", "Product not found."))
            : product.ToDto();
    }

    public async Task<Result<ProductDto>> CreateProductAsync(CreateProductRequest request, CancellationToken ct = default)
    {
        var product = new Product(request.Name, request.Category, request.CurrentStock, request.MinStock,
            request.PurchasePrice, request.SalePrice);
        _db.Products.Add(product);
        await _db.SaveChangesAsync(ct);
        return product.ToDto();
    }

    public async Task<Result<ProductDto>> UpdateProductAsync(Guid id, UpdateProductRequest request, CancellationToken ct = default)
    {
        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (product is null) return Result.Failure<ProductDto>(Error.NotFound("product.not_found", "Product not found."));

        product.Update(request.Name, request.Category, request.MinStock, request.PurchasePrice, request.SalePrice);
        await _db.SaveChangesAsync(ct);
        return product.ToDto();
    }

    public async Task<Result> SetProductActiveAsync(Guid id, bool active, CancellationToken ct = default)
    {
        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (product is null) return Result.Failure(Error.NotFound("product.not_found", "Product not found."));

        if (active) product.Activate(); else product.Deactivate();
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    public async Task<IReadOnlyList<InventoryMovementDto>> ListMovementsAsync(Guid productId, CancellationToken ct = default)
    {
        var movements = await _db.InventoryMovements
            .Where(m => m.ProductId == productId)
            .OrderByDescending(m => m.CreatedAtUtc)
            .ToListAsync(ct);
        return movements.Select(m => m.ToDto()).ToList();
    }

    public async Task<Result<InventoryMovementDto>> RegisterMovementAsync(CreateMovementRequest request, CancellationToken ct = default)
    {
        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == request.ProductId, ct);
        if (product is null)
            return Result.Failure<InventoryMovementDto>(Error.NotFound("product.not_found", "Product not found."));

        var movement = new InventoryMovement(request.ProductId, request.Type, request.Quantity,
            request.AppointmentId, request.ClientId, request.UnitPrice, request.Notes);

        try
        {
            // Sales/consumption reduce stock; purchases/adjustments add to it.
            product.AdjustStock(movement.StockDelta);
        }
        catch (InvalidOperationException)
        {
            return Result.Failure<InventoryMovementDto>(
                Error.Conflict("inventory.insufficient_stock", "The resulting stock cannot be negative."));
        }

        _db.InventoryMovements.Add(movement);
        await _db.SaveChangesAsync(ct);
        return movement.ToDto();
    }
}
