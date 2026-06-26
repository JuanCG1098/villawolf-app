using VillaWolf.Application.Appointments.Dtos;
using VillaWolf.Application.Calendar.Dtos;
using VillaWolf.Application.Cashbox.Dtos;
using VillaWolf.Application.Catalog.Dtos;
using VillaWolf.Application.Clients.Dtos;
using VillaWolf.Application.Employees.Dtos;
using VillaWolf.Application.Inventory.Dtos;
using VillaWolf.Application.Notifications.Dtos;
using VillaWolf.Application.Scheduling.Dtos;
using VillaWolf.Domain.Entities;

namespace VillaWolf.Application.Common.Mapping;

/// <summary>Pure projections from domain entities to DTOs. Entities are never exposed directly.</summary>
public static class MappingExtensions
{
    public static EmployeeDto ToDto(this Employee employee)
        => new(
            employee.Id,
            employee.UserId,
            employee.FirstName,
            employee.LastName,
            employee.FullName,
            employee.Phone,
            employee.ColorHex,
            employee.Bio,
            employee.AllowsOverbooking,
            employee.IsActive);

    public static WorkingHourDto ToDto(this WorkingHour workingHour)
        => new(workingHour.Id, workingHour.EmployeeId, workingHour.DayOfWeek,
            workingHour.StartTime, workingHour.EndTime, workingHour.IsActive);

    public static TimeBlockDto ToDto(this TimeBlock timeBlock)
        => new(timeBlock.Id, timeBlock.EmployeeId, timeBlock.StartUtc, timeBlock.EndUtc,
            timeBlock.Reason, timeBlock.Notes);

    public static PaymentDto ToDto(this Payment payment)
        => new(payment.Id, payment.AppointmentId, payment.Amount, payment.Method, payment.Type,
            payment.DiscountAmount, payment.Notes, payment.CreatedAtUtc);

    public static ProductDto ToDto(this Product product)
        => new(product.Id, product.Name, product.Category, product.CurrentStock, product.MinStock,
            product.PurchasePrice, product.SalePrice, product.IsActive, product.IsLowStock);

    public static InventoryMovementDto ToDto(this InventoryMovement movement)
        => new(movement.Id, movement.ProductId, movement.Type, movement.Quantity, movement.StockDelta,
            movement.AppointmentId, movement.ClientId, movement.UnitPrice, movement.Notes, movement.CreatedAtUtc);

    public static CalendarIntegrationDto ToDto(this GoogleCalendarIntegration integration)
        => new(integration.Id, integration.OwnerType, integration.EmployeeId, integration.GoogleCalendarId,
            integration.SyncEnabled, integration.LastSyncUtc);

    public static NotificationDto ToDto(this Notification n)
        => new(n.Id, n.Type, n.Channel, n.RecipientType, n.RecipientId, n.AppointmentId,
            n.ScheduledForUtc, n.Status, n.SentAtUtc, n.Payload);

    public static CategoryDto ToDto(this ServiceCategory category)
        => new(category.Id, category.Name, category.DisplayOrder);

    public static ServiceDto ToDto(this Service service)
        => new(
            service.Id,
            service.Name,
            service.Description,
            service.DurationMinutes,
            service.BasePrice,
            service.CategoryId,
            service.Category?.Name ?? string.Empty,
            service.TargetAudience,
            service.RequiresPreparation,
            service.AllowsAddons,
            service.IsActive);

    public static AddonDto ToDto(this ServiceAddon addon)
        => new(addon.Id, addon.Name, addon.ExtraDurationMinutes, addon.ExtraPrice, addon.TargetAudience, addon.IsActive);

    public static ClientDto ToDto(this Client client)
        => new(
            client.Id,
            client.FirstName,
            client.LastName,
            client.FullName,
            client.Phone,
            client.Email,
            client.BirthDate,
            client.Notes,
            client.Preferences,
            client.IsActive,
            client.CreatedAtUtc);

    public static ClientListItemDto ToListItem(this Client client)
        => new(client.Id, client.FullName, client.Phone, client.Email, client.IsActive);

    public static AppointmentAddonDto ToDto(this AppointmentAddon addon)
        => new(addon.Id, addon.ServiceAddonId, addon.NameSnapshot, addon.PriceSnapshot, addon.DurationSnapshot);

    public static AppointmentDto ToDto(this Appointment appointment)
        => new(
            appointment.Id,
            appointment.ClientId,
            appointment.EmployeeId,
            appointment.ServiceId,
            appointment.ServiceNameSnapshot,
            appointment.StartUtc,
            appointment.EndUtc,
            appointment.TotalDurationMinutes,
            appointment.TotalPrice,
            appointment.Status,
            appointment.BookingChannel,
            appointment.InternalNotes,
            appointment.DepositAmount,
            appointment.PaymentMethod,
            appointment.Addons.Select(a => a.ToDto()).ToList());

    public static AppointmentListItemDto ToListItem(this Appointment appointment)
        => new(
            appointment.Id,
            appointment.ClientId,
            appointment.EmployeeId,
            appointment.ServiceNameSnapshot,
            appointment.StartUtc,
            appointment.EndUtc,
            appointment.TotalPrice,
            appointment.Status);
}
