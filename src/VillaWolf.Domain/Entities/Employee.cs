using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A staff member (barber/stylist, reception or admin) linked 1:1 to an identity user.
/// Deactivated rather than deleted so appointment history is preserved.
/// </summary>
public class Employee : EntityBase
{
    private Employee() { }

    public Employee(Guid userId, string firstName, string lastName, string? phone, string colorHex)
    {
        UserId = userId;
        FirstName = firstName;
        LastName = lastName;
        Phone = phone;
        ColorHex = string.IsNullOrWhiteSpace(colorHex) ? "#C8A24B" : colorHex;
        IsActive = true;
    }

    /// <summary>Identity user this employee signs in with.</summary>
    public Guid UserId { get; private set; }
    public string FirstName { get; private set; } = null!;
    public string LastName { get; private set; } = null!;
    public string? Phone { get; private set; }

    /// <summary>Colour used to render this employee's appointments in the calendar.</summary>
    public string ColorHex { get; private set; } = "#C8A24B";
    public string? Bio { get; private set; }

    /// <summary>When true, the admin allows overbooking this employee's agenda.</summary>
    public bool AllowsOverbooking { get; private set; }
    public bool IsActive { get; private set; } = true;

    public string FullName => $"{FirstName} {LastName}";

    public void Update(string firstName, string lastName, string? phone, string colorHex, string? bio)
    {
        FirstName = firstName;
        LastName = lastName;
        Phone = phone;
        ColorHex = string.IsNullOrWhiteSpace(colorHex) ? ColorHex : colorHex;
        Bio = bio;
        Touch();
    }

    public void SetOverbooking(bool allowed) { AllowsOverbooking = allowed; Touch(); }
    public void Activate() { IsActive = true; Touch(); }
    public void Deactivate() { IsActive = false; Touch(); }
}
