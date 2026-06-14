using VillaWolf.Domain.Common;
using VillaWolf.Domain.Enums;

namespace VillaWolf.Domain.Entities;

/// <summary>
/// A booked appointment for one client with one employee. The main service's price and duration are
/// snapshotted; total price and duration (and the end time) are derived from the snapshot plus any
/// add-ons. Overlap prevention per employee is also enforced at the database level via an exclusion
/// constraint.
/// </summary>
public class Appointment : EntityBase
{
    private readonly List<AppointmentAddon> _addons = new();

    private Appointment() { }

    public Appointment(Guid clientId, Guid employeeId, Service service, DateTime startUtc,
        BookingChannel bookingChannel, string? internalNotes)
    {
        ClientId = clientId;
        EmployeeId = employeeId;
        ServiceId = service.Id;
        ServiceNameSnapshot = service.Name;
        ServicePriceSnapshot = service.BasePrice;
        ServiceDurationSnapshot = service.DurationMinutes;
        StartUtc = DateTime.SpecifyKind(startUtc, DateTimeKind.Utc);
        BookingChannel = bookingChannel;
        InternalNotes = internalNotes;
        Status = AppointmentStatus.Pending;
        Recalculate();
    }

    public Guid ClientId { get; private set; }
    public Guid EmployeeId { get; private set; }

    public Guid ServiceId { get; private set; }
    public string ServiceNameSnapshot { get; private set; } = null!;
    public decimal ServicePriceSnapshot { get; private set; }
    public int ServiceDurationSnapshot { get; private set; }

    public DateTime StartUtc { get; private set; }
    public DateTime EndUtc { get; private set; }
    public int TotalDurationMinutes { get; private set; }
    public decimal TotalPrice { get; private set; }

    public AppointmentStatus Status { get; private set; }
    public string? InternalNotes { get; private set; }
    public BookingChannel BookingChannel { get; private set; }

    public decimal? DepositAmount { get; private set; }
    public PaymentMethod? PaymentMethod { get; private set; }

    /// <summary>Google Calendar event id, when this appointment is synced.</summary>
    public string? GoogleEventId { get; private set; }

    public IReadOnlyCollection<AppointmentAddon> Addons => _addons.AsReadOnly();

    public void AddAddon(ServiceAddon addon)
    {
        _addons.Add(new AppointmentAddon(Id, addon));
        Recalculate();
        Touch();
    }

    public void ClearAddons()
    {
        _addons.Clear();
        Recalculate();
        Touch();
    }

    public void Reschedule(DateTime newStartUtc)
    {
        EnsureNotClosed();
        StartUtc = DateTime.SpecifyKind(newStartUtc, DateTimeKind.Utc);
        Recalculate();
        Touch();
    }

    public void SetDeposit(decimal amount, PaymentMethod method)
    {
        if (amount < 0) throw new ArgumentException("Deposit cannot be negative.", nameof(amount));
        DepositAmount = amount;
        PaymentMethod = method;
        Touch();
    }

    public void LinkGoogleEvent(string eventId) { GoogleEventId = eventId; Touch(); }

    public void Confirm() { Transition(AppointmentStatus.Confirmed); }
    public void Start() { Transition(AppointmentStatus.InProgress); }
    public void Complete() { Transition(AppointmentStatus.Completed); }
    public void MarkNoShow() { Transition(AppointmentStatus.NoShow); }

    public void Cancel()
    {
        if (Status is AppointmentStatus.Completed)
            throw new InvalidOperationException("A completed appointment cannot be cancelled.");
        Status = AppointmentStatus.Cancelled;
        Touch();
    }

    private void Transition(AppointmentStatus target)
    {
        if (Status is AppointmentStatus.Cancelled or AppointmentStatus.Completed or AppointmentStatus.NoShow)
            throw new InvalidOperationException($"Cannot move a {Status} appointment to {target}.");
        Status = target;
        Touch();
    }

    private void EnsureNotClosed()
    {
        if (Status is AppointmentStatus.Cancelled or AppointmentStatus.Completed or AppointmentStatus.NoShow)
            throw new InvalidOperationException($"A {Status} appointment cannot be rescheduled.");
    }

    private void Recalculate()
    {
        TotalDurationMinutes = ServiceDurationSnapshot + _addons.Sum(a => a.DurationSnapshot);
        TotalPrice = ServicePriceSnapshot + _addons.Sum(a => a.PriceSnapshot);
        EndUtc = StartUtc.AddMinutes(TotalDurationMinutes);
    }
}
