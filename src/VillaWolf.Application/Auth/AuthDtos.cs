namespace VillaWolf.Application.Auth;

public sealed record LoginRequest(string Email, string Password);

public sealed record AuthResponse(
    Guid UserId,
    string DisplayName,
    string Email,
    string Role,
    string AccessToken,
    DateTime ExpiresAtUtc);
