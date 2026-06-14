# CLAUDE.md

Context for AI assistants (and humans) working in this repository.

## What this is

**Villa Wolf** — a management app for a unisex barbershop/salon: appointments, services, clients,
staff agendas/availability, cash-box, inventory, security-camera monitoring and reminders. Backend
**.NET 10** (Clean Architecture), frontend **Flutter** (web + mobile, from Iteration 4). Built
iteratively — see [docs/ITERATIONS.md](docs/ITERATIONS.md).

## Stack & layout

`Api → Application / Infrastructure → Domain` (dependencies point inwards).

```
src/VillaWolf.Domain          # entities, enums, Result/Error — no framework deps
src/VillaWolf.Application      # use cases, DTOs, validators, abstractions (IAuthService, ...)
src/VillaWolf.Infrastructure   # EF Core AppDbContext, Identity+JWT, repositories, migrations, seed
src/VillaWolf.Api              # controllers, Program, Swagger
```

EF Core 10 + PostgreSQL (Npgsql) · ASP.NET Core Identity + JWT · FluentValidation · Serilog · Swagger.

## Common commands

Solution file is **`VillaWolf.slnx`** (pass it explicitly to `dotnet`).

```bash
dotnet build VillaWolf.slnx
docker compose up --build            # Postgres + API, auto-migrate + seed; Swagger at http://localhost:8080
dotnet run --project src/VillaWolf.Api   # needs ConnectionStrings__Default

# EF Core migrations
dotnet ef migrations add <Name> \
  --project src/VillaWolf.Infrastructure \
  --startup-project src/VillaWolf.Api \
  --output-dir Persistence/Migrations
```

Default admin: `admin@villawolf.local` / `Admin123$`.

## Conventions (follow when editing)

- **Rich domain model.** Entities enforce invariants; no public setters. Create via constructors,
  change state via methods (`Appointment.Confirm/Cancel/Reschedule`, `Service.Deactivate`, ...).
- **Result pattern, not exceptions, for expected failures.** Application returns `Result`/`Result<T>`
  with an `Error(code, message, ErrorType)`; `ResultExtensions` maps `ErrorType` to HTTP status
  (Validation→400, NotFound→404, Conflict→409, Unauthorized→401).
- **Price/duration snapshots** on `Appointment`/`AppointmentAddon` — never recompute from the live
  catalogue.
- **Application-assigned GUID keys** (`ValueGeneratedNever`); **enums stored as strings**; **decimals
  (18,2)** — all applied globally in `AppDbContext.ApplyGlobalConventions`.
- **UTC everywhere**; display timezone in `BusinessSettings`.
- **Soft-delete** (`IsActive`) instead of deleting catalogue/staff.
- New use cases go in **feature folders** under Application (e.g. `Appointments/`, `Clients/`).

## Gotchas

- Pass the `.slnx` explicitly to `dotnet`.
- **Swashbuckle 10 / Microsoft.OpenApi 2.0**: types live in namespace `Microsoft.OpenApi` (no
  `.Models`); security requirements use `OpenApiSecuritySchemeReference` and `AddSecurityRequirement`
  takes a `Func<OpenApiDocument, OpenApiSecurityRequirement>`. See `Program.cs`.
- The **no-overlap** rule is enforced by a DB exclusion constraint (`ex_appointments_no_overlap`,
  needs `btree_gist`) added in the `InitialCreate` migration — keep it when regenerating migrations.
- Cameras module is **device admin/monitoring only**: no facial recognition, no biometric data.
