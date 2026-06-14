using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Application.Employees.Dtos;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;

namespace VillaWolf.Application.Employees;

public sealed class EmployeeService : IEmployeeService
{
    private static readonly string[] AllowedRoles = ["Admin", "Barber", "Reception"];

    private readonly IAppDbContext _db;
    private readonly IUserAccountService _userAccounts;

    public EmployeeService(IAppDbContext db, IUserAccountService userAccounts)
    {
        _db = db;
        _userAccounts = userAccounts;
    }

    public async Task<IReadOnlyList<EmployeeDto>> ListAsync(bool includeInactive, CancellationToken ct = default)
    {
        var query = _db.Employees.AsQueryable();
        if (!includeInactive) query = query.Where(e => e.IsActive);
        var employees = await query.OrderBy(e => e.FirstName).ThenBy(e => e.LastName).ToListAsync(ct);
        return employees.Select(e => e.ToDto()).ToList();
    }

    public async Task<Result<EmployeeDto>> GetAsync(Guid id, CancellationToken ct = default)
    {
        var employee = await _db.Employees.FirstOrDefaultAsync(e => e.Id == id, ct);
        return employee is null
            ? Result.Failure<EmployeeDto>(Error.NotFound("employee.not_found", "Employee not found."))
            : employee.ToDto();
    }

    public async Task<Result<EmployeeDto>> CreateAsync(CreateEmployeeRequest request, CancellationToken ct = default)
    {
        if (!AllowedRoles.Contains(request.Role))
            return Result.Failure<EmployeeDto>(Error.Validation("employee.invalid_role",
                $"Role must be one of: {string.Join(", ", AllowedRoles)}."));

        var userResult = await _userAccounts.CreateUserAsync(
            request.Email, request.Password, $"{request.FirstName} {request.LastName}", request.Role, ct);
        if (userResult.IsFailure)
            return Result.Failure<EmployeeDto>(userResult.Error);

        var employee = new Employee(userResult.Value, request.FirstName, request.LastName, request.Phone,
            request.ColorHex ?? "#C8A24B");
        if (!string.IsNullOrWhiteSpace(request.Bio))
            employee.Update(request.FirstName, request.LastName, request.Phone, request.ColorHex ?? "#C8A24B", request.Bio);

        _db.Employees.Add(employee);
        await _db.SaveChangesAsync(ct);
        return employee.ToDto();
    }

    public async Task<Result<EmployeeDto>> UpdateAsync(Guid id, UpdateEmployeeRequest request, CancellationToken ct = default)
    {
        var employee = await _db.Employees.FirstOrDefaultAsync(e => e.Id == id, ct);
        if (employee is null)
            return Result.Failure<EmployeeDto>(Error.NotFound("employee.not_found", "Employee not found."));

        employee.Update(request.FirstName, request.LastName, request.Phone, request.ColorHex, request.Bio);
        employee.SetOverbooking(request.AllowsOverbooking);
        await _db.SaveChangesAsync(ct);
        return employee.ToDto();
    }

    public async Task<Result> SetActiveAsync(Guid id, bool active, CancellationToken ct = default)
    {
        var employee = await _db.Employees.FirstOrDefaultAsync(e => e.Id == id, ct);
        if (employee is null) return Result.Failure(Error.NotFound("employee.not_found", "Employee not found."));

        if (active) employee.Activate(); else employee.Deactivate();
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }
}
