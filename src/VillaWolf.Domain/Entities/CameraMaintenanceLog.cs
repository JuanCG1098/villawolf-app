using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>A maintenance/inspection record for a <see cref="CameraDevice"/>.</summary>
public class CameraMaintenanceLog : EntityBase
{
    private CameraMaintenanceLog() { }

    public CameraMaintenanceLog(Guid cameraDeviceId, string description, string? performedBy, int? batteryLevelAfter)
    {
        CameraDeviceId = cameraDeviceId;
        Description = description;
        PerformedBy = performedBy;
        BatteryLevelAfter = batteryLevelAfter;
        PerformedAtUtc = DateTime.UtcNow;
    }

    public Guid CameraDeviceId { get; private set; }
    public string Description { get; private set; } = null!;
    public string? PerformedBy { get; private set; }
    public int? BatteryLevelAfter { get; private set; }
    public DateTime PerformedAtUtc { get; private set; }
}
