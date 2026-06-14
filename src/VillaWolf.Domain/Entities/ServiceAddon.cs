using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// An optional extra that can be attached to an appointment (e.g. Beard, Eyebrows, Premium product),
/// adding its own duration and price.
/// </summary>
public class ServiceAddon : EntityBase
{
    private ServiceAddon() { }

    public ServiceAddon(string name, int extraDurationMinutes, decimal extraPrice,
        ServiceTargetAudience targetAudience)
    {
        if (extraDurationMinutes < 0)
            throw new ArgumentException("Extra duration cannot be negative.", nameof(extraDurationMinutes));
        if (extraPrice < 0)
            throw new ArgumentException("Extra price cannot be negative.", nameof(extraPrice));

        Name = name;
        ExtraDurationMinutes = extraDurationMinutes;
        ExtraPrice = extraPrice;
        TargetAudience = targetAudience;
        IsActive = true;
    }

    public string Name { get; private set; } = null!;
    public int ExtraDurationMinutes { get; private set; }
    public decimal ExtraPrice { get; private set; }
    public ServiceTargetAudience TargetAudience { get; private set; }
    public bool IsActive { get; private set; } = true;

    public void Update(string name, int extraDurationMinutes, decimal extraPrice,
        ServiceTargetAudience targetAudience)
    {
        if (extraDurationMinutes < 0)
            throw new ArgumentException("Extra duration cannot be negative.", nameof(extraDurationMinutes));
        if (extraPrice < 0)
            throw new ArgumentException("Extra price cannot be negative.", nameof(extraPrice));

        Name = name;
        ExtraDurationMinutes = extraDurationMinutes;
        ExtraPrice = extraPrice;
        TargetAudience = targetAudience;
        Touch();
    }

    public void Activate() { IsActive = true; Touch(); }
    public void Deactivate() { IsActive = false; Touch(); }
}
