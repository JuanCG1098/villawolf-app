using VillaWolf.Domain.Common;

namespace VillaWolf.Application.Abstractions;

/// <summary>
/// Creates identity users for staff. Implemented in Infrastructure over ASP.NET Core Identity so the
/// application layer can create employees without depending on Identity directly.
/// </summary>
public interface IUserAccountService
{
    Task<Result<Guid>> CreateUserAsync(string email, string password, string displayName, string role,
        CancellationToken cancellationToken = default);
}
