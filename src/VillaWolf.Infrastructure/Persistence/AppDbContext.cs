using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using VillaWolf.Application.Abstractions;
using VillaWolf.Domain.Common;
using VillaWolf.Domain.Entities;
using VillaWolf.Infrastructure.Identity;

namespace VillaWolf.Infrastructure.Persistence;

/// <summary>
/// EF Core context for both Identity and the domain. Domain keys are application-assigned
/// (<c>ValueGeneratedNever</c>); all enums are stored as strings and all decimals use precision
/// (18,2). Appointment overlap per employee is additionally enforced by a database exclusion
/// constraint (added in the initial migration, requires the <c>btree_gist</c> extension).
/// </summary>
public class AppDbContext : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>, IAppDbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<Client> Clients => Set<Client>();
    public DbSet<ServiceCategory> ServiceCategories => Set<ServiceCategory>();
    public DbSet<Service> Services => Set<Service>();
    public DbSet<ServiceAddon> ServiceAddons => Set<ServiceAddon>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<AppointmentAddon> AppointmentAddons => Set<AppointmentAddon>();
    public DbSet<WorkingHour> WorkingHours => Set<WorkingHour>();
    public DbSet<TimeBlock> TimeBlocks => Set<TimeBlock>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<InventoryMovement> InventoryMovements => Set<InventoryMovement>();
    public DbSet<CameraDevice> CameraDevices => Set<CameraDevice>();
    public DbSet<CameraMaintenanceLog> CameraMaintenanceLogs => Set<CameraMaintenanceLog>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<GoogleCalendarIntegration> GoogleCalendarIntegrations => Set<GoogleCalendarIntegration>();
    public DbSet<BusinessSettings> BusinessSettings => Set<BusinessSettings>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Required for the appointment-overlap exclusion constraint.
        modelBuilder.HasPostgresExtension("btree_gist");

        modelBuilder.Entity<Employee>(b =>
        {
            b.HasOne<ApplicationUser>()
                .WithOne()
                .HasForeignKey<Employee>(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            b.HasIndex(e => e.UserId).IsUnique();
        });

        modelBuilder.Entity<Client>(b =>
        {
            b.Property(c => c.Preferences).HasColumnType("jsonb");
            b.HasIndex(c => new { c.LastName, c.FirstName });
        });

        modelBuilder.Entity<Service>(b =>
        {
            b.HasOne(s => s.Category)
                .WithMany(c => c.Services)
                .HasForeignKey(s => s.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });
        modelBuilder.Entity<ServiceCategory>()
            .Navigation(c => c.Services).UsePropertyAccessMode(PropertyAccessMode.Field);

        modelBuilder.Entity<Appointment>(b =>
        {
            b.HasMany(a => a.Addons)
                .WithOne()
                .HasForeignKey(aa => aa.AppointmentId)
                .OnDelete(DeleteBehavior.Cascade);
            b.Navigation(a => a.Addons).UsePropertyAccessMode(PropertyAccessMode.Field);
            b.HasIndex(a => new { a.EmployeeId, a.StartUtc });
            b.HasIndex(a => a.ClientId);
            b.HasIndex(a => a.Status);
        });

        modelBuilder.Entity<CameraDevice>(b =>
        {
            b.HasMany(c => c.MaintenanceLogs)
                .WithOne()
                .HasForeignKey(l => l.CameraDeviceId)
                .OnDelete(DeleteBehavior.Cascade);
            b.Navigation(c => c.MaintenanceLogs).UsePropertyAccessMode(PropertyAccessMode.Field);
        });

        modelBuilder.Entity<WorkingHour>().HasIndex(w => new { w.EmployeeId, w.DayOfWeek });
        modelBuilder.Entity<TimeBlock>().HasIndex(t => new { t.EmployeeId, t.StartUtc });
        modelBuilder.Entity<Payment>().HasIndex(p => p.AppointmentId);
        modelBuilder.Entity<InventoryMovement>().HasIndex(m => m.ProductId);

        ApplyGlobalConventions(modelBuilder);
    }

    /// <summary>
    /// Cross-cutting mapping applied to every domain entity: application-assigned keys, enums stored
    /// as strings, and decimal precision (18,2). Done in one place so new entities inherit it.
    /// </summary>
    private static void ApplyGlobalConventions(ModelBuilder modelBuilder)
    {
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            // Application-assigned GUID keys for domain entities (leave Identity keys untouched).
            if (typeof(EntityBase).IsAssignableFrom(entityType.ClrType))
            {
                var idProperty = entityType.FindProperty(nameof(EntityBase.Id));
                if (idProperty is not null) idProperty.ValueGenerated = ValueGenerated.Never;
            }

            foreach (var property in entityType.GetProperties())
            {
                var clrType = Nullable.GetUnderlyingType(property.ClrType) ?? property.ClrType;

                if (clrType.IsEnum)
                {
                    var converterType = typeof(EnumToStringConverter<>).MakeGenericType(clrType);
                    property.SetValueConverter((ValueConverter)Activator.CreateInstance(converterType)!);
                    property.SetMaxLength(40);
                }
                else if (clrType == typeof(decimal))
                {
                    property.SetPrecision(18);
                    property.SetScale(2);
                }
            }
        }
    }
}
