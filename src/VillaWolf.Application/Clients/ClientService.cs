using Microsoft.EntityFrameworkCore;
using VillaWolf.Application.Abstractions;
using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Application.Clients.Dtos;
using VillaWolf.Application.Common.Mapping;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;

namespace VillaWolf.Application.Clients;

public sealed class ClientService : IClientService
{
    private readonly IAppDbContext _db;

    public ClientService(IAppDbContext db) => _db = db;

    public async Task<IReadOnlyList<ClientListItemDto>> ListAsync(string? search, bool includeInactive, CancellationToken ct = default)
    {
        var query = _db.Clients.AsQueryable();
        if (!includeInactive) query = query.Where(c => c.IsActive);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(c =>
                c.FirstName.ToLower().Contains(term) ||
                c.LastName.ToLower().Contains(term) ||
                (c.Phone != null && c.Phone.Contains(term)) ||
                (c.Email != null && c.Email.ToLower().Contains(term)));
        }

        var clients = await query.OrderBy(c => c.LastName).ThenBy(c => c.FirstName).ToListAsync(ct);
        return clients.Select(c => c.ToListItem()).ToList();
    }

    public async Task<Result<ClientDto>> GetAsync(Guid id, CancellationToken ct = default)
    {
        var client = await _db.Clients.FirstOrDefaultAsync(c => c.Id == id, ct);
        return client is null
            ? Result.Failure<ClientDto>(Error.NotFound("client.not_found", "Client not found."))
            : client.ToDto();
    }

    public async Task<Result<ClientDto>> CreateAsync(CreateClientRequest request, CancellationToken ct = default)
    {
        var client = new Client(request.FirstName, request.LastName, request.Phone, request.Email, request.BirthDate);
        client.Update(request.FirstName, request.LastName, request.Phone, request.Email, request.BirthDate,
            request.Notes, request.Preferences);
        _db.Clients.Add(client);
        await _db.SaveChangesAsync(ct);
        return client.ToDto();
    }

    public async Task<Result<ClientDto>> UpdateAsync(Guid id, UpdateClientRequest request, CancellationToken ct = default)
    {
        var client = await _db.Clients.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return Result.Failure<ClientDto>(Error.NotFound("client.not_found", "Client not found."));

        client.Update(request.FirstName, request.LastName, request.Phone, request.Email, request.BirthDate,
            request.Notes, request.Preferences);
        await _db.SaveChangesAsync(ct);
        return client.ToDto();
    }

    public async Task<Result> SetActiveAsync(Guid id, bool active, CancellationToken ct = default)
    {
        var client = await _db.Clients.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return Result.Failure(Error.NotFound("client.not_found", "Client not found."));

        if (active) client.Activate(); else client.Deactivate();
        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }

    public async Task<Result<IReadOnlyList<AppointmentListItemDto>>> GetHistoryAsync(Guid id, CancellationToken ct = default)
    {
        if (!await _db.Clients.AnyAsync(c => c.Id == id, ct))
            return Result.Failure<IReadOnlyList<AppointmentListItemDto>>(
                Error.NotFound("client.not_found", "Client not found."));

        var appointments = await _db.Appointments
            .Where(a => a.ClientId == id)
            .OrderByDescending(a => a.StartUtc)
            .ToListAsync(ct);

        return Result.Success<IReadOnlyList<AppointmentListItemDto>>(
            appointments.Select(a => a.ToListItem()).ToList());
    }
}
