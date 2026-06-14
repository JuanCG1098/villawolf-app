using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace VillaWolf.Infrastructure.Persistence;

/// <summary>
/// Lets the EF Core CLI build <see cref="AppDbContext"/> without booting the full API host
/// (so design-time commands like <c>migrations add</c> work standalone).
/// </summary>
public sealed class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql("Host=localhost;Port=5432;Database=villawolf;Username=postgres;Password=postgres")
            .Options;

        return new AppDbContext(options);
    }
}
