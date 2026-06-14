using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// An add-on attached to an appointment. Name, price and duration are snapshotted at booking time
/// so the appointment total never changes if the underlying add-on is later edited.
/// </summary>
public class AppointmentAddon : EntityBase
{
    private AppointmentAddon() { }

    public AppointmentAddon(Guid appointmentId, ServiceAddon addon)
    {
        AppointmentId = appointmentId;
        ServiceAddonId = addon.Id;
        NameSnapshot = addon.Name;
        PriceSnapshot = addon.ExtraPrice;
        DurationSnapshot = addon.ExtraDurationMinutes;
    }

    public Guid AppointmentId { get; private set; }
    public Guid ServiceAddonId { get; private set; }
    public string NameSnapshot { get; private set; } = null!;
    public decimal PriceSnapshot { get; private set; }
    public int DurationSnapshot { get; private set; }
}
