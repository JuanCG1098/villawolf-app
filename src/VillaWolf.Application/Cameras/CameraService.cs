using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Cameras.Dtos;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Cameras;

public interface ICameraService
{
    Task<IReadOnlyList<CameraDto>> ListAsync(CancellationToken ct = default);
    Task<Result<CameraDto>> GetAsync(Guid id, CancellationToken ct = default);
    Task<Result<CameraDto>> CreateAsync(CreateCameraRequest request, CancellationToken ct = default);
    Task<Result<CameraDto>> UpdateAsync(Guid id, UpdateCameraRequest request, CancellationToken ct = default);
    Task<Result<CameraDto>> SetStatusAsync(Guid id, CameraStatus status, CancellationToken ct = default);
    Task<Result<CameraDto>> ReportBatteryAsync(Guid id, int level, CancellationToken ct = default);
    Task<Result<MaintenanceLogDto>> RegisterMaintenanceAsync(Guid id, CreateMaintenanceRequest request, CancellationToken ct = default);
    Task<Result<IReadOnlyList<MaintenanceLogDto>>> ListMaintenanceAsync(Guid id, CancellationToken ct = default);
}

public sealed class CameraService : ICameraService
{
    private readonly IAppDbContext _db;

    public CameraService(IAppDbContext db) => _db = db;

    public async Task<IReadOnlyList<CameraDto>> ListAsync(CancellationToken ct = default)
    {
        var cameras = await _db.CameraDevices.OrderBy(c => c.Name).ToListAsync(ct);
        return cameras.Select(c => c.ToDto()).ToList();
    }

    public async Task<Result<CameraDto>> GetAsync(Guid id, CancellationToken ct = default)
    {
        var camera = await _db.CameraDevices.FirstOrDefaultAsync(c => c.Id == id, ct);
        return camera is null
            ? Result.Failure<CameraDto>(Error.NotFound("camera.not_found", "Camera not found."))
            : camera.ToDto();
    }

    public async Task<Result<CameraDto>> CreateAsync(CreateCameraRequest request, CancellationToken ct = default)
    {
        var camera = new CameraDevice(request.Name, request.Location, request.PowerType, request.ExternalStreamUrl);
        if (!string.IsNullOrWhiteSpace(request.Notes))
            camera.Update(request.Name, request.Location, request.PowerType, request.ExternalStreamUrl, request.Notes);

        _db.CameraDevices.Add(camera);
        await _db.SaveChangesAsync(ct);
        return camera.ToDto();
    }

    public async Task<Result<CameraDto>> UpdateAsync(Guid id, UpdateCameraRequest request, CancellationToken ct = default)
    {
        var camera = await _db.CameraDevices.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (camera is null) return Result.Failure<CameraDto>(Error.NotFound("camera.not_found", "Camera not found."));

        camera.Update(request.Name, request.Location, request.PowerType, request.ExternalStreamUrl, request.Notes);
        await _db.SaveChangesAsync(ct);
        return camera.ToDto();
    }

    public async Task<Result<CameraDto>> SetStatusAsync(Guid id, CameraStatus status, CancellationToken ct = default)
    {
        var camera = await _db.CameraDevices.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (camera is null) return Result.Failure<CameraDto>(Error.NotFound("camera.not_found", "Camera not found."));

        camera.SetStatus(status);
        await _db.SaveChangesAsync(ct);
        return camera.ToDto();
    }

    public async Task<Result<CameraDto>> ReportBatteryAsync(Guid id, int level, CancellationToken ct = default)
    {
        var camera = await _db.CameraDevices.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (camera is null) return Result.Failure<CameraDto>(Error.NotFound("camera.not_found", "Camera not found."));

        camera.ReportBattery(level);
        await _db.SaveChangesAsync(ct);
        return camera.ToDto();
    }

    public async Task<Result<MaintenanceLogDto>> RegisterMaintenanceAsync(Guid id, CreateMaintenanceRequest request, CancellationToken ct = default)
    {
        var camera = await _db.CameraDevices.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (camera is null) return Result.Failure<MaintenanceLogDto>(Error.NotFound("camera.not_found", "Camera not found."));

        var log = camera.RegisterMaintenance(request.Description, request.PerformedBy, request.BatteryLevelAfter);
        await _db.SaveChangesAsync(ct);
        return log.ToDto();
    }

    public async Task<Result<IReadOnlyList<MaintenanceLogDto>>> ListMaintenanceAsync(Guid id, CancellationToken ct = default)
    {
        if (!await _db.CameraDevices.AnyAsync(c => c.Id == id, ct))
            return Result.Failure<IReadOnlyList<MaintenanceLogDto>>(Error.NotFound("camera.not_found", "Camera not found."));

        var logs = await _db.CameraMaintenanceLogs
            .Where(l => l.CameraDeviceId == id)
            .OrderByDescending(l => l.PerformedAtUtc)
            .ToListAsync(ct);
        return Result.Success<IReadOnlyList<MaintenanceLogDto>>(logs.Select(l => l.ToDto()).ToList());
    }
}
