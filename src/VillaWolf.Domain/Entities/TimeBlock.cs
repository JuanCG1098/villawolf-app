using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A blocked interval during which no appointments can be booked: breaks, lunch, maintenance,
/// holidays, vacations or absences. A null <see cref="EmployeeId"/> blocks the whole shop.
/// </summary>
public class TimeBlock : EntityBase
{
    private TimeBlock() { }

    public TimeBlock(Guid? employeeId, DateTime startUtc, DateTime endUtc, TimeBlockReason reason, string? notes)
    {
        if (endUtc <= startUtc)
            throw new ArgumentException("End must be after start.", nameof(endUtc));

        EmployeeId = employeeId;
        StartUtc = DateTime.SpecifyKind(startUtc, DateTimeKind.Utc);
        EndUtc = DateTime.SpecifyKind(endUtc, DateTimeKind.Utc);
        Reason = reason;
        Notes = notes;
    }

    public Guid? EmployeeId { get; private set; }
    public DateTime StartUtc { get; private set; }
    public DateTime EndUtc { get; private set; }
    public TimeBlockReason Reason { get; private set; }
    public string? Notes { get; private set; }
}
