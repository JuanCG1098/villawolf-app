using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Inventory.Dtos;

public sealed record ProductDto(
    Guid Id,
    string Name,
    string Category,
    int CurrentStock,
    int MinStock,
    decimal PurchasePrice,
    decimal? SalePrice,
    bool IsActive,
    bool IsLowStock);

public sealed record CreateProductRequest(
    string Name,
    string Category,
    int CurrentStock,
    int MinStock,
    decimal PurchasePrice,
    decimal? SalePrice);

public sealed record UpdateProductRequest(
    string Name,
    string Category,
    int MinStock,
    decimal PurchasePrice,
    decimal? SalePrice);

public sealed record InventoryMovementDto(
    Guid Id,
    Guid ProductId,
    InventoryMovementType Type,
    int Quantity,
    int StockDelta,
    Guid? AppointmentId,
    Guid? ClientId,
    decimal? UnitPrice,
    string? Notes,
    DateTime CreatedAtUtc);

public sealed record CreateMovementRequest(
    Guid ProductId,
    InventoryMovementType Type,
    int Quantity,
    Guid? AppointmentId,
    Guid? ClientId,
    decimal? UnitPrice,
    string? Notes);
