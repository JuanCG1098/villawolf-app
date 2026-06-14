# Architecture

## Layers

Clean Architecture; dependencies point inwards.

```
        ┌─────────────────────────────┐
        │            Api              │  controllers, middleware, Swagger, Program
        └──────────────┬──────────────┘
        ┌──────────────┴──────────────┐
        │  Application & Infrastructure│  use cases + EF Core / Identity / JWT
        └──────────────┬──────────────┘
        ┌──────────────┴──────────────┐
        │           Domain            │  entities, enums, Result/Error (no frameworks)
        └─────────────────────────────┘
```

- **Domain** — entities with invariants and behaviour (no public setters; state changes via
  methods), enums, and the `Result`/`Error` types. No framework dependencies.
- **Application** — use-case services, DTOs, FluentValidation validators, and persistence/service
  abstractions (e.g. `IAuthService`). Depends only on Domain.
- **Infrastructure** — EF Core `AppDbContext`, Identity + JWT, repositories, migrations and the seed.
  Implements the Application abstractions.
- **Api** — thin controllers that translate `Result` into HTTP responses (ProblemDetails), Swagger
  with JWT bearer, Serilog, CORS, and startup migration + seeding.

## Data model (summary)

Personas & security: `ApplicationUser` (Identity) · roles · `Employee` (1:1 user) · `Client`.
Catalogue: `ServiceCategory` · `Service` · `ServiceAddon`.
Booking: `Appointment` · `AppointmentAddon`.
Agenda: `WorkingHour` · `TimeBlock`.
Operations: `Payment` · `Product` · `InventoryMovement` · `CameraDevice` · `CameraMaintenanceLog`.
Cross-cutting: `Notification` · `GoogleCalendarIntegration` · `BusinessSettings`.

## Key design decisions

- **Price/duration snapshots.** An `Appointment` snapshots the service's name, price and duration
  (and each add-on's) at booking time, so editing the catalogue never rewrites history. Total price
  and duration — and the end time — are derived from the snapshot plus add-ons.
- **DB-enforced no-overlap.** Besides application checks (later iteration), a PostgreSQL exclusion
  constraint (`btree_gist`) makes two overlapping appointments for the same employee physically
  impossible. Cancelled/no-show appointments are excluded so their slots free up.
- **UTC everywhere.** All instants are stored as `timestamptz` in UTC; the display timezone lives in
  `BusinessSettings.TimeZoneId`.
- **Soft-delete.** Services, add-ons, products and employees are deactivated (`IsActive`), never
  deleted, to preserve history.
- **Application-assigned GUID keys** (`ValueGeneratedNever`) so graphs are fully built in memory and
  newly-added children are always inserted, not mistaken for updates.
- **Enums as strings** in both the database and the API for readability and stability.
- **Single-tenant** for the MVP (`BusinessSettings` is a single row); the design leaves room for
  multi-tenancy later.

## Request lifecycle (example: login)

1. `POST /api/auth/login` → `AuthController`.
2. `IAuthService` (Infrastructure) verifies the password via Identity's `UserManager`.
3. On success it issues a signed JWT with the user's role claims; on failure it returns a
   `Result.Failure(Unauthorized)` that the controller maps to HTTP 401.
4. The token authorizes subsequent calls (`[Authorize]`), validated by the JWT bearer middleware.
