namespace VillaWolf.Application.Clients.Dtos;

public sealed record ClientDto(
    Guid Id,
    string FirstName,
    string LastName,
    string FullName,
    string? Phone,
    string? Email,
    DateOnly? BirthDate,
    string? Notes,
    string? Preferences,
    bool IsActive,
    DateTime CreatedAtUtc);

public sealed record ClientListItemDto(
    Guid Id,
    string FullName,
    string? Phone,
    string? Email,
    bool IsActive);

public sealed record CreateClientRequest(
    string FirstName,
    string LastName,
    string? Phone,
    string? Email,
    DateOnly? BirthDate,
    string? Notes,
    string? Preferences);

public sealed record UpdateClientRequest(
    string FirstName,
    string LastName,
    string? Phone,
    string? Email,
    DateOnly? BirthDate,
    string? Notes,
    string? Preferences);
