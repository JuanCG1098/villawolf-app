using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// Single-row configuration for the barbershop: identity, contact, timezone, currency and the
/// minimum agenda slot size. Modelled as an entity so it can be edited from the settings screen.
/// </summary>
public class BusinessSettings : EntityBase
{
    private BusinessSettings() { }

    public BusinessSettings(string name, string timeZoneId, string currencyCode, int minSlotMinutes)
    {
        Name = name;
        TimeZoneId = timeZoneId;
        CurrencyCode = currencyCode;
        MinSlotMinutes = NormalizeSlot(minSlotMinutes);
    }

    public string Name { get; private set; } = null!;
    public string? Address { get; private set; }
    public string? Phone { get; private set; }
    public string? Email { get; private set; }
    public string? Instagram { get; private set; }
    public string? LogoUrl { get; private set; }

    /// <summary>IANA/Windows timezone id used to interpret working hours and render the calendar.</summary>
    public string TimeZoneId { get; private set; } = "America/Argentina/Buenos_Aires";
    public string CurrencyCode { get; private set; } = "ARS";

    /// <summary>Granularity of the agenda grid in minutes (15, 30 or 60).</summary>
    public int MinSlotMinutes { get; private set; } = 30;

    public void Update(string name, string? address, string? phone, string? email, string? instagram,
        string? logoUrl, string timeZoneId, string currencyCode, int minSlotMinutes)
    {
        Name = name;
        Address = address;
        Phone = phone;
        Email = email;
        Instagram = instagram;
        LogoUrl = logoUrl;
        TimeZoneId = timeZoneId;
        CurrencyCode = currencyCode;
        MinSlotMinutes = NormalizeSlot(minSlotMinutes);
        Touch();
    }

    private static int NormalizeSlot(int minutes) => minutes is 15 or 30 or 60 ? minutes : 30;
}
