using VillaWolf.Domain.Common;

namespace VillaWolf.Application.Auth;

/// <summary>
/// Authenticates users and issues JWTs. Implemented in the infrastructure layer over ASP.NET Core
/// Identity so the rest of the application depends only on this abstraction.
/// </summary>
public interface IAuthService
{
    Task<Result<AuthResponse>> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
}
