using VillaWolf.Domain.Common;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// Opening hours for a given day of week. A null <see cref="EmployeeId"/> means business-wide
/// hours; a value means an override for that specific employee.
/// </summary>
public class WorkingHour : EntityBase
{
    private WorkingHour() { }

    public WorkingHour(Guid? employeeId, DayOfWeek dayOfWeek, TimeOnly startTime, TimeOnly endTime)
    {
        if (endTime <= startTime)
            throw new ArgumentException("End time must be after start time.", nameof(endTime));

        EmployeeId = employeeId;
        DayOfWeek = dayOfWeek;
        StartTime = startTime;
        EndTime = endTime;
        IsActive = true;
    }

    public Guid? EmployeeId { get; private set; }
    public DayOfWeek DayOfWeek { get; private set; }
    public TimeOnly StartTime { get; private set; }
    public TimeOnly EndTime { get; private set; }
    public bool IsActive { get; private set; } = true;

    public void Update(TimeOnly startTime, TimeOnly endTime, bool isActive)
    {
        if (endTime <= startTime)
            throw new ArgumentException("End time must be after start time.", nameof(endTime));
        StartTime = startTime;
        EndTime = endTime;
        IsActive = isActive;
        Touch();
    }
}
