using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using VillaWolf.Domain.Entities;
using VillaWolf.Domain.Enums;
using VillaWolf.Infrastructure.Identity;

namespace VillaWolf.Infrastructure.Persistence.Seed;

/// <summary>
/// Idempotent seed: roles, an admin user, the business settings row and a typical unisex-barbershop
/// service catalogue. Safe to run on every startup.
/// </summary>
public static class DbSeeder
{
    public const string AdminEmail = "admin@villawolf.local";
    public const string AdminPassword = "Admin123$";
    public static readonly string[] Roles = ["Admin", "Barber", "Reception", "Client"];

    public static async Task SeedAsync(
        AppDbContext db,
        UserManager<ApplicationUser> users,
        RoleManager<IdentityRole<Guid>> roles)
    {
        await SeedRolesAsync(roles);
        await SeedAdminAsync(users);
        await SeedEmployeesAsync(db, users);
        await SeedBusinessAsync(db);
        await SeedWorkingHoursAsync(db);
        await SeedCatalogAsync(db);
        await SeedProductsAsync(db);
        await SeedCamerasAsync(db);
        await SeedDemoActivityAsync(db);
    }

    /// <summary>
    /// Demo appointments (mixed statuses for today + tomorrow), payments for the completed ones and a
    /// stock consumption — so the dashboard, cash-box and calendar show meaningful content on first run.
    /// </summary>
    private static async Task SeedDemoActivityAsync(AppDbContext db)
    {
        if (await db.Appointments.AnyAsync()) return;

        var employee = await db.Employees.FirstOrDefaultAsync();
        var services = await db.Services.OrderBy(s => s.Name).ToListAsync();
        if (employee is null || services.Count < 4) return;

        var clients = new[]
        {
            new Client("Martina", "Gómez", "+54 11 4444-1111", "martina@example.com", new DateOnly(1992, 4, 12)),
            new Client("Lucía", "Fernández", "+54 11 4444-2222", null, null),
            new Client("Diego", "Pérez", "+54 11 4444-3333", "diego@example.com", null),
            new Client("Sofía", "Ramírez", null, null, null),
        };
        db.Clients.AddRange(clients);

        var today = DateTime.UtcNow.Date;
        Appointment Make(Client client, Service service, int hourUtc)
        {
            var start = DateTime.SpecifyKind(today.AddHours(hourUtc), DateTimeKind.Utc);
            return new Appointment(client.Id, employee.Id, service, start, BookingChannel.Manual, null);
        }

        var completed1 = Make(clients[0], services[0], 12);
        completed1.Confirm(); completed1.Start(); completed1.Complete();
        var completed2 = Make(clients[1], services[1], 13);
        completed2.Confirm(); completed2.Complete();
        var confirmed = Make(clients[2], services[2], 14);
        confirmed.Confirm();
        var pending = Make(clients[3], services[3], 16);            // Coloración (90') -> ends 17:30
        var cancelled = Make(clients[0], services[0], 17);
        cancelled.Cancel();                                          // excluded from the no-overlap rule
        var tomorrow = Make(clients[1], services[0], 36);
        tomorrow.Confirm();

        db.Appointments.AddRange(completed1, completed2, confirmed, pending, cancelled, tomorrow);

        db.Payments.AddRange(
            new Payment(completed1.Id, completed1.TotalPrice, PaymentMethod.Cash, PaymentType.Payment, 0, null, null),
            new Payment(completed1.Id, 500m, PaymentMethod.Cash, PaymentType.Tip, 0, null, null),
            new Payment(completed2.Id, completed2.TotalPrice, PaymentMethod.Card, PaymentType.Payment, 0, null, null));

        var product = await db.Products.FirstOrDefaultAsync();
        if (product is not null)
        {
            var movement = new InventoryMovement(product.Id, InventoryMovementType.Consumption, 1,
                completed1.Id, clients[0].Id, null, "Uso en servicio");
            product.AdjustStock(movement.StockDelta);
            db.InventoryMovements.Add(movement);
        }

        await db.SaveChangesAsync();
    }

    private static async Task SeedProductsAsync(AppDbContext db)
    {
        if (await db.Products.AnyAsync()) return;

        db.Products.AddRange(
            new Product("Cera mate", "Styling", 24, 5, 3500m, 7000m),
            new Product("Shampoo", "Cuidado", 12, 4, 4200m, 8000m),
            new Product("Aceite para barba", "Barba", 3, 5, 5000m, 9500m), // below minimum
            new Product("Toallas", "Insumos", 40, 10, 1200m, null));

        await db.SaveChangesAsync();
    }

    private static async Task SeedCamerasAsync(AppDbContext db)
    {
        if (await db.CameraDevices.AnyAsync()) return;

        var entrance = new CameraDevice("Cámara Entrada", "Entrada", CameraPowerType.Solar, null);
        entrance.ReportBattery(85);
        var till = new CameraDevice("Cámara Caja", "Caja", CameraPowerType.Electric, null);
        var storage = new CameraDevice("Cámara Depósito", "Depósito", CameraPowerType.Solar, null);
        storage.ReportBattery(15); // low battery alert

        db.CameraDevices.AddRange(entrance, till, storage);
        await db.SaveChangesAsync();
    }

    private static async Task SeedWorkingHoursAsync(AppDbContext db)
    {
        if (await db.WorkingHours.AnyAsync()) return;

        DayOfWeek[] weekdays =
            [DayOfWeek.Monday, DayOfWeek.Tuesday, DayOfWeek.Wednesday, DayOfWeek.Thursday, DayOfWeek.Friday];
        foreach (var day in weekdays)
            db.WorkingHours.Add(new WorkingHour(null, day, new TimeOnly(9, 0), new TimeOnly(18, 0)));

        db.WorkingHours.Add(new WorkingHour(null, DayOfWeek.Saturday, new TimeOnly(9, 0), new TimeOnly(14, 0)));
        await db.SaveChangesAsync();
    }

    private static async Task SeedEmployeesAsync(AppDbContext db, UserManager<ApplicationUser> users)
    {
        if (await db.Employees.AnyAsync()) return;

        const string email = "barber@villawolf.local";
        var user = await users.FindByEmailAsync(email);
        if (user is null)
        {
            user = new ApplicationUser
            {
                Id = Guid.NewGuid(),
                UserName = email,
                Email = email,
                EmailConfirmed = true,
                DisplayName = "Lucas Wolf"
            };
            var result = await users.CreateAsync(user, "Barber123$");
            if (!result.Succeeded) return;
            await users.AddToRoleAsync(user, "Barber");
        }

        db.Employees.Add(new Employee(user.Id, "Lucas", "Wolf", "+54 11 5555-1234", "#C8B68A"));
        await db.SaveChangesAsync();
    }

    private static async Task SeedRolesAsync(RoleManager<IdentityRole<Guid>> roles)
    {
        foreach (var role in Roles)
            if (!await roles.RoleExistsAsync(role))
                await roles.CreateAsync(new IdentityRole<Guid>(role) { Id = Guid.NewGuid() });
    }

    private static async Task SeedAdminAsync(UserManager<ApplicationUser> users)
    {
        if (await users.FindByEmailAsync(AdminEmail) is not null) return;

        var admin = new ApplicationUser
        {
            Id = Guid.NewGuid(),
            UserName = AdminEmail,
            Email = AdminEmail,
            EmailConfirmed = true,
            DisplayName = "Villa Wolf Admin"
        };

        var result = await users.CreateAsync(admin, AdminPassword);
        if (result.Succeeded) await users.AddToRoleAsync(admin, "Admin");
    }

    private static async Task SeedBusinessAsync(AppDbContext db)
    {
        if (await db.BusinessSettings.AnyAsync()) return;
        db.BusinessSettings.Add(new BusinessSettings(
            "VILLAWOLF — hair studio", "America/Argentina/Buenos_Aires", "ARS", 30));
        await db.SaveChangesAsync();
    }

    private static async Task SeedCatalogAsync(AppDbContext db)
    {
        if (await db.ServiceCategories.AnyAsync()) return;

        var hair = new ServiceCategory("Cabello", 1);
        var beard = new ServiceCategory("Barba", 2);
        var color = new ServiceCategory("Color", 3);
        var treatments = new ServiceCategory("Tratamientos", 4);
        db.ServiceCategories.AddRange(hair, beard, color, treatments);

        db.Services.AddRange(
            new Service("Corte de pelo (hombre)", "Corte clásico o moderno", 30, 6000m, hair.Id, ServiceTargetAudience.Male, false, true),
            new Service("Corte + barba", "Corte completo con perfilado de barba", 50, 9000m, hair.Id, ServiceTargetAudience.Male, false, true),
            new Service("Barba", "Perfilado y arreglo de barba", 20, 4000m, beard.Id, ServiceTargetAudience.Male, false, true),
            new Service("Afeitado tradicional", "Afeitado con navaja y toalla caliente", 30, 5500m, beard.Id, ServiceTargetAudience.Male, true, true),
            new Service("Corte de pelo (mujer)", "Corte y estilo", 45, 8000m, hair.Id, ServiceTargetAudience.Female, false, true),
            new Service("Brushing", "Lavado y brushing", 40, 6500m, hair.Id, ServiceTargetAudience.Female, false, true),
            new Service("Coloración", "Aplicación de color", 90, 15000m, color.Id, ServiceTargetAudience.Unisex, true, true),
            new Service("Tratamiento capilar", "Nutrición e hidratación", 40, 7000m, treatments.Id, ServiceTargetAudience.Unisex, false, true));

        db.ServiceAddons.AddRange(
            new ServiceAddon("Lavado", 10, 1500m, ServiceTargetAudience.Unisex),
            new ServiceAddon("Cejas", 10, 2000m, ServiceTargetAudience.Unisex),
            new ServiceAddon("Peinado", 15, 2500m, ServiceTargetAudience.Unisex),
            new ServiceAddon("Producto premium", 0, 3000m, ServiceTargetAudience.Unisex));

        await db.SaveChangesAsync();
    }
}
