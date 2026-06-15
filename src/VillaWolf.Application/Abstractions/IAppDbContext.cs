using Microsoft.EntityFrameworkCore;
using VillaWolf.Domain.Entities;

namespace VillaWolf.Application.Abstractions;

/// <summary>
/// Persistence abstraction the application layer depends on. Exposes the aggregates needed by use
/// cases plus <see cref="SaveChangesAsync"/>; implemented by the EF Core context in Infrastructure.
/// </summary>
public interface IAppDbContext
{
    DbSet<Employee> Employees { get; }
    DbSet<Client> Clients { get; }
    DbSet<ServiceCategory> ServiceCategories { get; }
    DbSet<Service> Services { get; }
    DbSet<ServiceAddon> ServiceAddons { get; }
    DbSet<Appointment> Appointments { get; }
    DbSet<AppointmentAddon> AppointmentAddons { get; }
    DbSet<WorkingHour> WorkingHours { get; }
    DbSet<TimeBlock> TimeBlocks { get; }
    DbSet<BusinessSettings> BusinessSettings { get; }
    DbSet<Payment> Payments { get; }
    DbSet<Product> Products { get; }
    DbSet<InventoryMovement> InventoryMovements { get; }
    DbSet<CameraDevice> CameraDevices { get; }
    DbSet<CameraMaintenanceLog> CameraMaintenanceLogs { get; }
    DbSet<GoogleCalendarIntegration> GoogleCalendarIntegrations { get; }
    DbSet<Notification> Notifications { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
