# Iterations Log

The project is built in iterations. Each entry records what was created, what works, how to test it,
and what comes next.

## Roadmap

| It. | Goal | Status |
| --- | --- | --- |
| **1** | Backend solution, data model, DbContext + migration, JWT/Identity, Swagger, Docker, seed | ✅ Done |
| 2 | Endpoints: services, add-ons, clients, appointments (auto duration/price) | ⏳ Next |
| 3 | Availability engine: overlap, working hours, blocks, overbooking; free-slots endpoint | ◻ |
| 4 | Flutter app: login, dashboard, calendar | ◻ |
| 5 | Cash-box, inventory (stock discount), cameras | ◻ |
| 6 | Google Calendar: decoupled design + mocked export | ◻ |
| 7 | UI polish, README, rich seeds, tests for critical rules | ◻ |

---

## Iteration 1 — Foundation ✅

### Created

- **Solution** `VillaWolf.slnx` with four projects: `Domain`, `Application`, `Infrastructure`, `Api`
  (`Directory.Build.props` with `NuGetAuditMode=direct`).
- **Domain** — `EntityBase`, `Result`/`Error`, all enums, and 17 entities: `Employee`, `Client`,
  `ServiceCategory`, `Service`, `ServiceAddon`, `Appointment`, `AppointmentAddon`, `WorkingHour`,
  `TimeBlock`, `Payment`, `Product`, `InventoryMovement`, `CameraDevice`, `CameraMaintenanceLog`,
  `Notification`, `GoogleCalendarIntegration`, `BusinessSettings`. Invariants live in the entities.
- **Application** — `IAuthService` + auth DTOs, FluentValidation wiring (`AddApplication`).
- **Infrastructure** — `ApplicationUser` (Identity, GUID key), `AppDbContext`
  (`IdentityDbContext` + domain sets; enums→string, decimals (18,2), `ValueGeneratedNever`,
  relationships, indexes, `btree_gist`), `AuthService` (JWT), `DbSeeder`,
  `DesignTimeDbContextFactory`, `AddInfrastructure` (DbContext, Identity, JWT auth).
- **Migration** `InitialCreate` — all tables incl. Identity, plus a hand-added **exclusion
  constraint** `ex_appointments_no_overlap` preventing overlapping appointments per employee.
- **Api** — `Program` (Serilog, Swagger+JWT, CORS, startup migrate+seed), `AuthController`
  (`/api/auth/login`, `/api/auth/me`), `ResultExtensions`, appsettings.
- **Infra/docs** — `Dockerfile`, `docker-compose.yml`, `.dockerignore`, `.gitignore`, `README.md`,
  `docs/architecture.md`, this log, `CLAUDE.md`.

### What works (verified live under Docker)

- `docker compose up --build` → Postgres healthy, API migrates + seeds on startup.
- Seed: 4 roles, 1 admin, 1 business settings, 4 service categories, 8 services, 4 add-ons.
- `POST /api/auth/login` (`admin@villawolf.local` / `Admin123$`) → **JWT** with role `Admin`.
- `GET /api/auth/me` with the bearer token → returns the user identity; **without** a token → **401**.
- `GET /swagger/v1/swagger.json` → **200**; Swagger UI at the root with an Authorize button.
- Database checks: `ex_appointments_no_overlap` exclusion constraint present, `btree_gist` enabled.

### How to test

```bash
docker compose up --build
# then:
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@villawolf.local","password":"Admin123$"}'
# copy the accessToken, then:
curl http://localhost:8080/api/auth/me -H "Authorization: Bearer <token>"
```

Or open <http://localhost:8080>, use **Authorize**, and try the endpoints.

### What's next (Iteration 2)

CRUD endpoints + application services for **services, add-ons, clients and appointments**, with
appointment total duration/price computed from the service + add-ons, DTOs, FluentValidation and
the `Result → ProblemDetails` mapping reused from this iteration.
