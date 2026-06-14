using Microsoft.AspNetCore.Identity;
using VillaWolf.Application.Abstractions;
using VillaWolf.Domain.Common;

namespace VillaWolf.Infrastructure.Identity;

public sealed class UserAccountService : IUserAccountService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<IdentityRole<Guid>> _roleManager;

    public UserAccountService(UserManager<ApplicationUser> userManager, RoleManager<IdentityRole<Guid>> roleManager)
    {
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task<Result<Guid>> CreateUserAsync(string email, string password, string displayName, string role,
        CancellationToken cancellationToken = default)
    {
        if (await _userManager.FindByEmailAsync(email) is not null)
            return Result.Failure<Guid>(Error.Conflict("user.email_taken", "A user with that email already exists."));

        if (!await _roleManager.RoleExistsAsync(role))
            return Result.Failure<Guid>(Error.Validation("user.invalid_role", "The role does not exist."));

        var user = new ApplicationUser
        {
            Id = Guid.NewGuid(),
            UserName = email,
            Email = email,
            EmailConfirmed = true,
            DisplayName = displayName
        };

        var result = await _userManager.CreateAsync(user, password);
        if (!result.Succeeded)
            return Result.Failure<Guid>(Error.Validation("user.create_failed",
                string.Join("; ", result.Errors.Select(e => e.Description))));

        await _userManager.AddToRoleAsync(user, role);
        return user.Id;
    }
}
