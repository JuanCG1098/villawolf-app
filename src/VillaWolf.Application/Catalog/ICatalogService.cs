using VillaWolf.Application.Catalog.Dtos;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Catalog;

public interface ICatalogService
{
    Task<IReadOnlyList<CategoryDto>> ListCategoriesAsync(CancellationToken ct = default);
    Task<Result<CategoryDto>> CreateCategoryAsync(CreateCategoryRequest request, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceDto>> ListServicesAsync(bool includeInactive, ServiceTargetAudience? audience, Guid? categoryId, CancellationToken ct = default);
    Task<Result<ServiceDto>> GetServiceAsync(Guid id, CancellationToken ct = default);
    Task<Result<ServiceDto>> CreateServiceAsync(CreateServiceRequest request, CancellationToken ct = default);
    Task<Result<ServiceDto>> UpdateServiceAsync(Guid id, UpdateServiceRequest request, CancellationToken ct = default);
    Task<Result> SetServiceActiveAsync(Guid id, bool active, CancellationToken ct = default);

    Task<IReadOnlyList<AddonDto>> ListAddonsAsync(bool includeInactive, CancellationToken ct = default);
    Task<Result<AddonDto>> GetAddonAsync(Guid id, CancellationToken ct = default);
    Task<Result<AddonDto>> CreateAddonAsync(CreateAddonRequest request, CancellationToken ct = default);
    Task<Result<AddonDto>> UpdateAddonAsync(Guid id, UpdateAddonRequest request, CancellationToken ct = default);
    Task<Result> SetAddonActiveAsync(Guid id, bool active, CancellationToken ct = default);
}
