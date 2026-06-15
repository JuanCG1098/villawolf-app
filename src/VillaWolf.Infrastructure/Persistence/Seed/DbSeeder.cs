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
