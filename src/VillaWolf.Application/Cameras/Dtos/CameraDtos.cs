using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Cameras.Dtos;

public sealed record CameraDto(
    Guid Id,
    string Name,
    string Location,
    CameraPowerType PowerType,
    CameraStatus Status,
    int? BatteryLevel,
    DateTime? LastCheckedAtUtc,
    string? Notes,
    string? ExternalStreamUrl,
    bool IsLowBattery);

public sealed record CreateCameraRequest(
    string Name,
    string Location,
    CameraPowerType PowerType,
    string? ExternalStreamUrl,
    string? Notes);

public sealed record UpdateCameraRequest(
    string Name,
    string Location,
    CameraPowerType PowerType,
    string? ExternalStreamUrl,
    string? Notes);

public sealed record SetCameraStatusRequest(CameraStatus Status);

public sealed record ReportBatteryRequest(int Level);

public sealed record CreateMaintenanceRequest(string Description, string? PerformedBy, int? BatteryLevelAfter);

public sealed record MaintenanceLogDto(
    Guid Id,
    Guid CameraDeviceId,
    string Description,
    string? PerformedBy,
    int? BatteryLevelAfter,
    DateTime PerformedAtUtc);
