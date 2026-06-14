using Microsoft.AspNetCore.Identity;

namespace VillaWolf.Infrastructure.Identity;

/// <summary>Identity user with a GUID key and a friendly display name.</summary>
public class ApplicationUser : IdentityUser<Guid>
{
    public string DisplayName { get; set; } = string.Empty;
}
