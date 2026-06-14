namespace VillaWolf.Application.Employees.Dtos;

public sealed record EmployeeDto(
    Guid Id,
    Guid UserId,
    string FirstName,
    string LastName,
    string FullName,
    string? Phone,
    string ColorHex,
    string? Bio,
    bool AllowsOverbooking,
    bool IsActive);

public sealed record CreateEmployeeRequest(
    string FirstName,
    string LastName,
    string? Phone,
    string Email,
    string Password,
    string Role,
    string? ColorHex,
    string? Bio);

public sealed record UpdateEmployeeRequest(
    string FirstName,
    string LastName,
    string? Phone,
    string ColorHex,
    string? Bio,
    bool AllowsOverbooking);
