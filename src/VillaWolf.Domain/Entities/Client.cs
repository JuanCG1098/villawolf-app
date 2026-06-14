using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A customer of the barbershop. Does not require a login (a customer-facing app is a later phase);
/// <see cref="UserId"/> can optionally link the client to an identity user then.
/// </summary>
public class Client : EntityBase
{
    private Client() { }

    public Client(string firstName, string lastName, string? phone, string? email, DateOnly? birthDate)
    {
        FirstName = firstName;
        LastName = lastName;
        Phone = phone;
        Email = email;
        BirthDate = birthDate;
        IsActive = true;
    }

    public string FirstName { get; private set; } = null!;
    public string LastName { get; private set; } = null!;
    public string? Phone { get; private set; }
    public string? Email { get; private set; }
    public DateOnly? BirthDate { get; private set; }

    /// <summary>Free-text observations about the client.</summary>
    public string? Notes { get; private set; }

    /// <summary>
    /// Flexible preferences (preferred cut, favourite barber, allergies, products to avoid) stored
    /// as JSON so the shape can evolve without a migration.
    /// </summary>
    public string? Preferences { get; private set; }

    /// <summary>Optional link to an identity user for the future client app.</summary>
    public Guid? UserId { get; private set; }
    public bool IsActive { get; private set; } = true;

    public string FullName => $"{FirstName} {LastName}";

    public void Update(string firstName, string lastName, string? phone, string? email,
        DateOnly? birthDate, string? notes, string? preferences)
    {
        FirstName = firstName;
        LastName = lastName;
        Phone = phone;
        Email = email;
        BirthDate = birthDate;
        Notes = notes;
        Preferences = preferences;
        Touch();
    }

    public void AttachUser(Guid userId) { UserId = userId; Touch(); }
    public void Activate() { IsActive = true; Touch(); }
    public void Deactivate() { IsActive = false; Touch(); }
}
