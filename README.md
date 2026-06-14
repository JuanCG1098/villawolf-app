# VILLAWOLF · hair studio — Management app

A full-stack management app for a unisex hair studio: appointments, services, clients, staff
agendas, availability, cash-box, inventory, device monitoring and reminders. Backend in **.NET 10**,
frontend in **Flutter** (web + mobile from one codebase).

> **Brand:** minimalist black & white, "VILLAWOLF" wordmark with the *hair studio* tagline and a
> circular ring motif. The Flutter UI (Iteration 4) follows this identity — see
> [docs/BRAND.md](docs/BRAND.md).

> **Status:** Iteration 1 complete — backend solution, full data model, database with migrations,
> JWT authentication and Swagger, all running under Docker. See
> [docs/ITERATIONS.md](docs/ITERATIONS.md) for the roadmap and per-iteration log.

## Tech stack

| Area | Technology |
| --- | --- |
| Language / runtime | C# / .NET 10 |
| Web API | ASP.NET Core (controllers) |
| Persistence | EF Core 10 + PostgreSQL (Npgsql) |
| Auth | ASP.NET Core Identity + JWT bearer |
| Validation / Logging / Docs | FluentValidation · Serilog · Swagger/OpenAPI |
| Frontend | Flutter (Web · Android · iOS) — *from Iteration 4* |
| Containers | Docker + Docker Compose |

## Architecture

Clean Architecture, dependencies pointing inwards: `Api → Application / Infrastructure → Domain`.
The domain is framework-free and holds entities, invariants and (in later iterations) the scheduling
logic. See [docs/architecture.md](docs/architecture.md).

```
src/
  VillaWolf.Domain          # entities, enums, Result/Error (no framework deps)
  VillaWolf.Application      # use cases, DTOs, validators, abstractions
  VillaWolf.Infrastructure   # EF Core, Identity/JWT, repositories, migrations, seed
  VillaWolf.Api              # controllers, middleware, Swagger, Program
```

## Why PostgreSQL

Beyond being free and Docker-friendly, PostgreSQL lets the **no-overlap rule for an employee's agenda
be enforced by the database itself** via an exclusion constraint
(`EXCLUDE USING gist (EmployeeId =, tstzrange(start, end) &&)`), not only in application code —
overlapping bookings are physically impossible. It also gives native `timestamptz` and `jsonb`
(used for flexible client preferences).

## Getting started

### Docker (recommended)

```bash
docker compose up --build
```

- API + Swagger UI: <http://localhost:8080>
- PostgreSQL: `localhost:5432` (`postgres` / `postgres`, db `villawolf`)

The database is migrated and seeded automatically on startup (roles, an admin user, business
settings and a typical service catalogue).

**Default admin login:** `admin@villawolf.local` / `Admin123$`

Try it: `POST /api/auth/login` with those credentials returns a JWT; paste it into Swagger's
**Authorize** button to call protected endpoints (e.g. `GET /api/auth/me`).

### Run the backend manually

Requires the .NET 10 SDK and a reachable PostgreSQL. Set the connection string and run:

```bash
export ConnectionStrings__Default="Host=localhost;Port=5432;Database=villawolf;Username=postgres;Password=postgres"
dotnet run --project src/VillaWolf.Api
```

## Roles

`Admin` · `Barber` (barber/stylist) · `Reception` · `Client` (customer app — later phase).

## Privacy note (security cameras)

The shop uses solar security cameras. The cameras module is **device administration and monitoring
only** — registering cameras, status, battery level and maintenance. It performs **no facial
recognition** and stores **no biometric data** of any kind.

## Roadmap

See [docs/ITERATIONS.md](docs/ITERATIONS.md). In short: data model & auth (done) → services/clients/
appointments → availability engine → Flutter app → cash-box/inventory/cameras → Google Calendar →
polish, seeds and tests.
