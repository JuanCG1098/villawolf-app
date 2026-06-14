using System.Reflection;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace VillaWolf.Application;

public static class DependencyInjection
{
    /// <summary>
    /// Registers application-layer services: FluentValidation validators discovered in this
    /// assembly (use-case services are added in later iterations).
    /// </summary>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly(), includeInternalTypes: true);
        return services;
    }
}
