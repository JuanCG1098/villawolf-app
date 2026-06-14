using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Catalog.Dtos;

public sealed record CategoryDto(Guid Id, string Name, int DisplayOrder);

public sealed record CreateCategoryRequest(string Name, int DisplayOrder);

public sealed record ServiceDto(
    Guid Id,
    string Name,
    string? Description,
    int DurationMinutes,
    decimal BasePrice,
    Guid CategoryId,
    string CategoryName,
    ServiceTargetAudience TargetAudience,
    bool RequiresPreparation,
    bool AllowsAddons,
    bool IsActive);

public sealed record CreateServiceRequest(
    string Name,
    string? Description,
    int DurationMinutes,
    decimal BasePrice,
    Guid CategoryId,
    ServiceTargetAudience TargetAudience,
    bool RequiresPreparation,
    bool AllowsAddons);

public sealed record UpdateServiceRequest(
    string Name,
    string? Description,
    int DurationMinutes,
    decimal BasePrice,
    Guid CategoryId,
    ServiceTargetAudience TargetAudience,
    bool RequiresPreparation,
    bool AllowsAddons);

public sealed record AddonDto(
    Guid Id,
    string Name,
    int ExtraDurationMinutes,
    decimal ExtraPrice,
    ServiceTargetAudience TargetAudience,
    bool IsActive);

public sealed record CreateAddonRequest(
    string Name,
    int ExtraDurationMinutes,
    decimal ExtraPrice,
    ServiceTargetAudience TargetAudience);

public sealed record UpdateAddonRequest(
    string Name,
    int ExtraDurationMinutes,
    decimal ExtraPrice,
    ServiceTargetAudience TargetAudience);
