using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A security camera registered for device administration and monitoring only. The shop uses solar
/// cameras; this module tracks status, battery and maintenance. It performs NO facial recognition
/// and stores NO biometric data.
/// </summary>
public class CameraDevice : EntityBase
{
    private readonly List<CameraMaintenanceLog> _maintenanceLogs = new();

    private CameraDevice() { }

    public CameraDevice(string name, string location, CameraPowerType powerType, string? externalStreamUrl)
    {
        Name = name;
        Location = location;
        PowerType = powerType;
        ExternalStreamUrl = externalStreamUrl;
        Status = CameraStatus.Active;
    }

    public string Name { get; private set; } = null!;

    /// <summary>Free-text placement: entrance, till, salon, storage, exterior, etc.</summary>
    public string Location { get; private set; } = null!;
    public CameraPowerType PowerType { get; private set; }
    public CameraStatus Status { get; private set; }

    /// <summary>Battery percentage (solar cameras); null when not applicable.</summary>
    public int? BatteryLevel { get; private set; }
    public DateTime? LastCheckedAtUtc { get; private set; }
    public string? Notes { get; private set; }
    public string? ExternalStreamUrl { get; private set; }

    public IReadOnlyCollection<CameraMaintenanceLog> MaintenanceLogs => _maintenanceLogs.AsReadOnly();

    /// <summary>True when a solar camera's battery is at or below the alert threshold.</summary>
    public bool IsLowBattery => BatteryLevel is not null && BatteryLevel <= 20;

    public void Update(string name, string location, CameraPowerType powerType, string? streamUrl, string? notes)
    {
        Name = name;
        Location = location;
        PowerType = powerType;
        ExternalStreamUrl = streamUrl;
        Notes = notes;
        Touch();
    }

    public void SetStatus(CameraStatus status) { Status = status; Touch(); }

    public void ReportBattery(int level)
    {
        BatteryLevel = Math.Clamp(level, 0, 100);
        LastCheckedAtUtc = DateTime.UtcNow;
        Touch();
    }

    public CameraMaintenanceLog RegisterMaintenance(string description, string? performedBy, int? batteryLevelAfter)
    {
        var log = new CameraMaintenanceLog(Id, description, performedBy, batteryLevelAfter);
        _maintenanceLogs.Add(log);
        LastCheckedAtUtc = DateTime.UtcNow;
        if (batteryLevelAfter is not null) BatteryLevel = Math.Clamp(batteryLevelAfter.Value, 0, 100);
        Touch();
        return log;
    }
}
