using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A service offered by the barbershop. Carries the default duration and base price; both are
/// snapshotted onto an appointment when booked, so changing them never rewrites history.
/// </summary>
public class Service : EntityBase
{
    private Service() { }

    public Service(string name, string? description, int durationMinutes, decimal basePrice,
        Guid categoryId, ServiceTargetAudience targetAudience, bool requiresPreparation, bool allowsAddons)
    {
        if (durationMinutes <= 0)
            throw new ArgumentException("Duration must be positive.", nameof(durationMinutes));
        if (basePrice < 0)
            throw new ArgumentException("Price cannot be negative.", nameof(basePrice));

        Name = name;
        Description = description;
        DurationMinutes = durationMinutes;
        BasePrice = basePrice;
        CategoryId = categoryId;
        TargetAudience = targetAudience;
        RequiresPreparation = requiresPreparation;
        AllowsAddons = allowsAddons;
        IsActive = true;
    }

    public string Name { get; private set; } = null!;
    public string? Description { get; private set; }
    public int DurationMinutes { get; private set; }
    public decimal BasePrice { get; private set; }

    public Guid CategoryId { get; private set; }
    public ServiceCategory? Category { get; private set; }

    public ServiceTargetAudience TargetAudience { get; private set; }
    public bool RequiresPreparation { get; private set; }
    public bool AllowsAddons { get; private set; }
    public bool IsActive { get; private set; } = true;

    public void Update(string name, string? description, int durationMinutes, decimal basePrice,
        Guid categoryId, ServiceTargetAudience targetAudience, bool requiresPreparation, bool allowsAddons)
    {
        if (durationMinutes <= 0)
            throw new ArgumentException("Duration must be positive.", nameof(durationMinutes));
        if (basePrice < 0)
            throw new ArgumentException("Price cannot be negative.", nameof(basePrice));

        Name = name;
        Description = description;
        DurationMinutes = durationMinutes;
        BasePrice = basePrice;
        CategoryId = categoryId;
        TargetAudience = targetAudience;
        RequiresPreparation = requiresPreparation;
        AllowsAddons = allowsAddons;
        Touch();
    }

    public void Activate() { IsActive = true; Touch(); }
    public void Deactivate() { IsActive = false; Touch(); }
}
