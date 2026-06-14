using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Application.Appointments;

public interface IAppointmentService
{
    Task<IReadOnlyList<AppointmentListItemDto>> ListAsync(
        DateTime? fromUtc, DateTime? toUtc, Guid? employeeId, Guid? clientId, AppointmentStatus? status,
        CancellationToken ct = default);

    Task<Result<AppointmentDto>> GetAsync(Guid id, CancellationToken ct = default);
    Task<Result<AppointmentDto>> CreateAsync(CreateAppointmentRequest request, CancellationToken ct = default);
    Task<Result<AppointmentDto>> RescheduleAsync(Guid id, DateTime newStartUtc, CancellationToken ct = default);

    Task<Result<AppointmentDto>> ConfirmAsync(Guid id, CancellationToken ct = default);
    Task<Result<AppointmentDto>> StartAsync(Guid id, CancellationToken ct = default);
    Task<Result<AppointmentDto>> CompleteAsync(Guid id, CancellationToken ct = default);
    Task<Result<AppointmentDto>> CancelAsync(Guid id, CancellationToken ct = default);
    Task<Result<AppointmentDto>> NoShowAsync(Guid id, CancellationToken ct = default);
}
