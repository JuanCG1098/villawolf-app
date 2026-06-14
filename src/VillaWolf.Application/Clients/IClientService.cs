using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Application.Clients.Dtos;
using VillaWolf.Domain.Common;

namespace VillaWolf.Application.Clients;

public interface IClientService
{
    Task<IReadOnlyList<ClientListItemDto>> ListAsync(string? search, bool includeInactive, CancellationToken ct = default);
    Task<Result<ClientDto>> GetAsync(Guid id, CancellationToken ct = default);
    Task<Result<ClientDto>> CreateAsync(CreateClientRequest request, CancellationToken ct = default);
    Task<Result<ClientDto>> UpdateAsync(Guid id, UpdateClientRequest request, CancellationToken ct = default);
    Task<Result> SetActiveAsync(Guid id, bool active, CancellationToken ct = default);
    Task<Result<IReadOnlyList<AppointmentListItemDto>>> GetHistoryAsync(Guid id, CancellationToken ct = default);
}
