using System.Reflection;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using VillaWolf.Application.Appointments;
using VillaWolf.Application.Calendar;
using VillaWolf.Application.Cameras;
using VillaWolf.Application.Cashbox;
using VillaWolf.Application.Catalog;
using VillaWolf.Application.Clients;
using VillaWolf.Application.Employees;
using VillaWolf.Application.Inventory;
using VillaWolf.Application.Scheduling;

namespace VillaWolf.Application;

public static class DependencyInjection
{
    /// <summary>
    /// Registers application-layer services and the FluentValidation validators discovered in this
    /// assembly.
    /// </summary>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly(), includeInternalTypes: true);

        services.AddScoped<ICatalogService, CatalogService>();
        services.AddScoped<IClientService, ClientService>();
        services.AddScoped<IAppointmentService, AppointmentService>();
        services.AddScoped<IEmployeeService, EmployeeService>();
        services.AddScoped<ISchedulingService, SchedulingService>();
        services.AddScoped<ICashboxService, CashboxService>();
        services.AddScoped<IInventoryService, InventoryService>();
        services.AddScoped<ICameraService, CameraService>();
        services.AddScoped<ICalendarService, CalendarService>();

        return services;
    }
}
