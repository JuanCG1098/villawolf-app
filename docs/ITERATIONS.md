# Iterations Log

The project is built in iterations. Each entry records what was created, what works, how to test it,
and what comes next.

## Roadmap

| It. | Goal | Status |
| --- | --- | --- |
| **1** | Backend solution, data model, DbContext + migration, JWT/Identity, Swagger, Docker, seed | ✅ Done |
| **2** | Endpoints: services, add-ons, clients, appointments (auto duration/price) | ✅ Done |
| **3** | Availability engine: overlap, working hours, blocks, overbooking; free-slots endpoint | ✅ Built + tested (Docker E2E pending) |
| **4** | Flutter app: login, dashboard, calendar | ✅ Built + compiles (runtime vs backend pending Docker) |
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

---

## Iteration 2 — Catalogue, clients & appointments ✅

### Created

- **Persistence abstraction** `IAppDbContext` (Application) implemented by `AppDbContext` — use-case
  services depend on it instead of per-entity repositories.
- **Catalog** (`CatalogService`): categories (list/create), services (list with filters/get/create/
  update/activate/deactivate), add-ons (list/get/create/update/activate/deactivate).
- **Clients** (`ClientService`): list with search, get, create, update, activate/deactivate, and
  appointment **history**.
- **Appointments** (`AppointmentService`): list (filters: date range, employee, client, status), get,
  create (auto **total duration & price** from service + add-ons, with snapshots), reschedule, and
  state transitions (confirm/start/complete/cancel/no-show). Overlap (the DB exclusion constraint) is
  translated to **HTTP 409**.
- DTOs + FluentValidation validators per feature; `MappingExtensions`; `ValidationFilter` (auto 400);
  controllers `ServiceCategories`, `Services`, `ServiceAddons`, `Clients`, `Appointments` with
  role-based authorization. Seed now also creates a sample **barber** (employee + user).

### What works (verified live under Docker)

- `GET /api/services` (8) and `/api/service-addons` (4) from the seed.
- `POST /api/clients` → created; `POST /api/appointments` with 2 add-ons →
  `end = start + 50m`, `totalPrice = 9000` (5500 + 1500 + 2000), `totalDurationMinutes = 50`.
- Overlapping appointment for the same employee → **409**.
- `POST /api/appointments/{id}/confirm` → `Confirmed`.
- Invalid client (empty name) → **400**; client history returns the booked appointment.

### How to test

Log in (`/api/auth/login`), then via Swagger or curl: list `/api/services` + `/api/service-addons`,
create a client, then `POST /api/appointments` with `serviceId`, `employeeId` (seeded barber),
`clientId`, `startUtc` and `addonIds`. Inspect the computed totals; try an overlapping booking to see
the 409.

### What's next (Iteration 3)

Availability engine: validate working hours, time blocks/holidays and overbooking authorization
*before* hitting the DB constraint, plus a **free-slots** endpoint per employee/day. Employees CRUD
and working-hours configuration also land here.

---

## Iteration 3 — Availability engine ✅ (verified via tests; Docker E2E pending)

> The code is complete, the whole solution **builds clean (0 warnings)**, and the availability engine
> is **verified by 7 passing integration tests** (`tests/VillaWolf.Tests`, xUnit + EF Core InMemory —
> no Docker needed): free-slot generation, working-hours/overlap validation, total computation, and
> overbooking. What remains for the Docker end-to-end run is only the DB-level exclusion constraint
> and real-Postgres timezone behaviour. (Docker Desktop on this machine currently can't create
> AF_UNIX sockets — a Winsock-level issue, fixed with an elevated `netsh winsock reset` + reboot.)

### Created

- **Employees** (`EmployeeService` + `IUserAccountService` implemented in Infrastructure): list, get,
  create (creates the identity user + role), update, activate/deactivate. New `EmployeesController`.
- **Scheduling** (`SchedulingService`): working-hours CRUD (per employee or business-wide), time-block
  CRUD (breaks/holidays/vacations), and the **availability engine**:
  - `GetFreeSlotsAsync(employee, date, service?)` — free start times for the day, honouring working
    hours, existing appointments and blocks, stepped by `BusinessSettings.MinSlotMinutes`, with
    timezone conversion (`BusinessSettings.TimeZoneId`).
  - `EnsureAvailableAsync(...)` — validates a requested slot is within working hours, not blocked and
    not overlapping; used by appointment create/reschedule before the DB constraint.
  - `ScheduleController` (`/api/schedule/working-hours`, `/time-blocks`, `/free-slots`).
- **Overbooking**: `Appointment.IsOverbooking`; the exclusion constraint was updated (migration
  `AddOverbooking`) to exclude overbooking rows, so an admin-authorized overbooking may share a slot.
  `AppointmentsController` honours `AllowOverbooking` only for Admins.
- Seed now also creates **business-wide working hours** (Mon–Fri 09–18, Sat 09–14).

### How it will be tested (once Docker is back)

Log in, `GET /api/schedule/free-slots?employeeId=&date=&serviceId=` (expect slots within 09–18),
book one slot, re-query (slot gone), try a booking outside hours (400 `availability.outside_hours`),
an overlapping booking (409), and an overlapping booking with `allowOverbooking=true` as Admin
(succeeds). Plus employee create and working-hours/time-block CRUD.

### What's next (Iteration 4)

Flutter app (web + mobile): login, dashboard and the calendar view — consuming these APIs, styled to
the monochrome VILLAWOLF brand (see [BRAND.md](BRAND.md)).

---

## Iteration 4 — Flutter app (login · dashboard · calendar) ✅ (compiles; runtime pending Docker)

Flutter app at `frontend/villawolf_app` (web + Android + iOS), monochrome VILLAWOLF theme.

### Created

- **Architecture**: Riverpod (state/DI) + go_router (auth-guarded routing) + Dio (HTTP). Feature-first
  layout under `lib/src` (`core`, `models`, `services`, `state`, `routing`, `ui`, `features`).
- **Core**: `AppConfig` (API base URL via `--dart-define=API_BASE_URL`), monochrome `AppTheme`,
  `Formatters`, `TokenStorage` (shared_preferences).
- **Auth**: `ApiService` + `AuthController` (login, `/me` restore on startup, logout); JWT attached by a
  Dio interceptor; go_router redirects between `/splash`, `/login` and the app shell.
- **UI**: responsive `AppShell` (sidebar on web, drawer on mobile), `BrandMark` (wordmark + ring),
  `MetricCard`, `StatusChip`, `SectionCard`.
- **Screens**: **Login** (pre-filled with the seeded admin), **Dashboard** (today's KPIs — counts,
  revenue, employees, services — and today's appointments), **Calendar** (per-professional day view
  with appointments and free slots from `/api/schedule/free-slots`).

### What works (verified)

- `flutter analyze` → **No issues found!**
- `flutter build web` → **builds successfully**.

Runtime against the live API is pending the Docker fix (Winsock); run with
`flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080` once the backend is up.

### What's next (Iteration 5)

Cash-box, inventory (with stock discount on consumption/sale) and the cameras module — backend
endpoints + their screens.
