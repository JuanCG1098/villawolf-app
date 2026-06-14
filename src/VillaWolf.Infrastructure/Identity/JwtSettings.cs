namespace VillaWolf.Infrastructure.Identity;

/// <summary>JWT options bound from the <c>Jwt</c> configuration section.</summary>
public sealed class JwtSettings
{
    public const string SectionName = "Jwt";

    public string Issuer { get; init; } = "VillaWolf";
    public string Audience { get; init; } = "VillaWolf";
    public string SecretKey { get; init; } = string.Empty;
    public int ExpiryMinutes { get; init; } = 480;
}
