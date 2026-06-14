using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>Grouping for services (e.g. Hair, Beard, Colour, Treatments).</summary>
public class ServiceCategory : EntityBase
{
    private readonly List<Service> _services = new();

    private ServiceCategory() { }

    public ServiceCategory(string name, int displayOrder)
    {
        Name = name;
        DisplayOrder = displayOrder;
    }

    public string Name { get; private set; } = null!;
    public int DisplayOrder { get; private set; }

    public IReadOnlyCollection<Service> Services => _services.AsReadOnly();

    public void Update(string name, int displayOrder)
    {
        Name = name;
        DisplayOrder = displayOrder;
        Touch();
    }
}
