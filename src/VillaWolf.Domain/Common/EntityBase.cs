namespace VillaWolf.Domain.Common;

/// <summary>
/// Base for all domain entities. Ids are application-assigned GUIDs (configured
/// <c>ValueGeneratedNever</c> in EF) so an entity is fully constructed in memory before it is
/// persisted, and freshly-added graph children are always treated as inserts.
/// </summary>
public abstract class EntityBase
{
    public Guid Id { get; protected set; } = Guid.NewGuid();

    public DateTime CreatedAtUtc { get; protected set; } = DateTime.UtcNow;

    public DateTime? UpdatedAtUtc { get; protected set; }

    protected void Touch() => UpdatedAtUtc = DateTime.UtcNow;
}
