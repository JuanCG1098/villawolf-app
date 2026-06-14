using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Catalog.Dtos;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Catalog;

public sealed class CatalogService : ICatalogService
{
    private readonly IAppDbContext _db;

    public CatalogService(IAppDbContext db) => _db = db;

    // ----- Categories -----

    public async Task<IReadOnlyList<CategoryDto>> ListCategoriesAsync(CancellationToken ct = default)
        => await _db.ServiceCategories
            .OrderBy(c => c.DisplayOrder)
            .Select(c => new CategoryDto(c.Id, c.Name, c.DisplayOrder))
            .ToListAsync(ct);

    public async Task<Result<CategoryDto>> CreateCategoryAsync(CreateCategoryRequest request, CancellationToken ct = default)
    {
        var category = new ServiceCategory(request.Name, request.DisplayOrder);
        _db.ServiceCategories.Add(category);
        await _db.SaveChangesAsync(ct);
        return category.ToDto();
    }

    // ----- Services -----

    public async Task<IReadOnlyList<ServiceDto>> ListServicesAsync(
        bool includeInactive, ServiceTargetAudience? audience, Guid? categoryId, CancellationToken ct = default)
    {
        var query = _db.Services.Include(s => s.Category).AsQueryable();
        if (!includeInactive) query = query.Where(s => s.IsActive);
        if (audience is not null) query = query.Where(s => s.TargetAudience == audience);
        if (categoryId is not null) query = query.Where(s => s.CategoryId == categoryId);

        var services = await query.OrderBy(s => s.Name).ToListAsync(ct);
        return services.Select(s => s.ToDto()).ToList();
    }

    public async Task<Result<ServiceDto>> GetServiceAsync(Guid id, CancellationToken ct = default)
    {
        var service = await _db.Services.Include(s => s.Category).FirstOrDefaultAsync(s => s.Id == id, ct);
        return service is null
            ? Result.Failure<ServiceDto>(Error.NotFound("service.not_found", "Service not found."))
            : service.ToDto();
    }

    public async Task<Result<ServiceDto>> CreateServiceAsync(CreateServiceRequest request, CancellationToken ct = default)
    {
        if (!await _db.ServiceCategories.AnyAsync(c => c.Id == request.CategoryId, ct))
            return Result.Failure<ServiceDto>(Error.Validation("service.category_not_found", "The category does not exist."));

        var service = new Service(request.Name, request.Description, request.DurationMinutes, request.BasePrice,
            request.CategoryId, request.TargetAudience, request.RequiresPreparation, request.AllowsAddons);

        _db.Services.Add(service);
        await _db.SaveChangesAsync(ct);
        return (await GetServiceAsync(service.Id, ct)).Value;
    }

    public async Task<Result<ServiceDto>> UpdateServiceAsync(Guid id, UpdateServiceRequest request, CancellationToken ct = default)
    {
        var service = await _db.Services.FirstOrDefaultAsync(s => s.Id == id, ct);
        if (service is null)
            return Result.Failure<ServiceDto>(Error.NotFound("service.not_found", "Service not found."));

        if (!await _db.ServiceCategories.AnyAsync(c => c.Id == request.CategoryId, ct))
            return Result.Failure<ServiceDto>(Error.Validation("service.category_not_found", "The category does not exist."));

        service.Update(request.Name, request.Description, request.DurationMinutes, request.BasePrice,
            request.CategoryId, request.TargetAudience, request.RequiresPreparation, request.AllowsAddons);
        await _db.SaveChangesAsync(ct);
        return (await GetServiceAsync(service.Id, ct)).Value;
    }

    public async Task<Result> SetServiceActiveAsync(Guid id, bool active, CancellationToken ct = default)
    {
        var service = await _db.Services.FirstOrDefaultAsync(s => s.Id == id, ct);
        if (service is null) return Result.Failure(Error.NotFound("service.not_found", "Service not found."));

        if (active) service.Activate(); else service.Deactivate();
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    // ----- Add-ons -----

    public async Task<IReadOnlyList<AddonDto>> ListAddonsAsync(bool includeInactive, CancellationToken ct = default)
    {
        var query = _db.ServiceAddons.AsQueryable();
        if (!includeInactive) query = query.Where(a => a.IsActive);
        return await query.OrderBy(a => a.Name)
            .Select(a => new AddonDto(a.Id, a.Name, a.ExtraDurationMinutes, a.ExtraPrice, a.TargetAudience, a.IsActive))
            .ToListAsync(ct);
    }

    public async Task<Result<AddonDto>> GetAddonAsync(Guid id, CancellationToken ct = default)
    {
        var addon = await _db.ServiceAddons.FirstOrDefaultAsync(a => a.Id == id, ct);
        return addon is null
            ? Result.Failure<AddonDto>(Error.NotFound("addon.not_found", "Add-on not found."))
            : addon.ToDto();
    }

    public async Task<Result<AddonDto>> CreateAddonAsync(CreateAddonRequest request, CancellationToken ct = default)
    {
        var addon = new ServiceAddon(request.Name, request.ExtraDurationMinutes, request.ExtraPrice, request.TargetAudience);
        _db.ServiceAddons.Add(addon);
        await _db.SaveChangesAsync(ct);
        return addon.ToDto();
    }

    public async Task<Result<AddonDto>> UpdateAddonAsync(Guid id, UpdateAddonRequest request, CancellationToken ct = default)
    {
        var addon = await _db.ServiceAddons.FirstOrDefaultAsync(a => a.Id == id, ct);
        if (addon is null) return Result.Failure<AddonDto>(Error.NotFound("addon.not_found", "Add-on not found."));

        addon.Update(request.Name, request.ExtraDurationMinutes, request.ExtraPrice, request.TargetAudience);
        await _db.SaveChangesAsync(ct);
        return addon.ToDto();
    }

    public async Task<Result> SetAddonActiveAsync(Guid id, bool active, CancellationToken ct = default)
    {
        var addon = await _db.ServiceAddons.FirstOrDefaultAsync(a => a.Id == id, ct);
        if (addon is null) return Result.Failure(Error.NotFound("addon.not_found", "Add-on not found."));

        if (active) addon.Activate(); else addon.Deactivate();
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }
}
