using VillaWolf.Application.Employees.Dtos;
using VillaWolf.Domain.Common;

namespace VillaWolf.Application.Employees;

public interface IEmployeeService
{
    Task<IReadOnlyList<EmployeeDto>> ListAsync(bool includeInactive, CancellationToken ct = default);
    Task<Result<EmployeeDto>> GetAsync(Guid id, CancellationToken ct = default);
    Task<Result<EmployeeDto>> CreateAsync(CreateEmployeeRequest request, CancellationToken ct = default);
    Task<Result<EmployeeDto>> UpdateAsync(Guid id, UpdateEmployeeRequest request, CancellationToken ct = default);
    Task<Result> SetActiveAsync(Guid id, bool active, CancellationToken ct = default);
}
