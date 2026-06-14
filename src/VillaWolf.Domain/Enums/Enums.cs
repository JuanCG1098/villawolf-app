namespace VillaWolf.Domain.Enums;

/// <summary>Who a service or add-on is intended for.</summary>
public enum ServiceTargetAudience { Male, Female, Unisex }

/// <summary>Lifecycle of an appointment.</summary>
public enum AppointmentStatus { Pending, Confirmed, InProgress, Completed, Cancelled, NoShow }

/// <summary>Where the booking originated.</summary>
public enum BookingChannel { Manual, Web, Mobile, GoogleCalendar }

public enum PaymentMethod { Cash, Transfer, Card, MercadoPago, Other }

/// <summary>Nature of a cash-box entry.</summary>
public enum PaymentType { Payment, Deposit, Tip, Refund }

/// <summary>Reason an agenda slot is blocked.</summary>
public enum TimeBlockReason { Break, Lunch, Maintenance, Errand, Vacation, Holiday, Other }

public enum InventoryMovementType { Purchase, Sale, Consumption, Adjustment }

public enum CameraPowerType { Solar, Electric }

public enum CameraStatus { Active, Inactive, Maintenance }

public enum NotificationType { Reminder, Confirmation, Cancellation, Reschedule, NoShow, DailyAgenda }

public enum NotificationChannel { WhatsApp, Email, Push }

public enum NotificationStatus { Pending, Sent, Failed, Mocked }

public enum NotificationRecipientType { Client, Employee }

/// <summary>Whether a Google Calendar link belongs to the business or a single employee.</summary>
public enum CalendarOwnerType { Business, Employee }
