# Technical Stack

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Selection criteria

The stack favors explicit data access, testability, a conventional Go service, stable Flutter packages, and minimal hosted infrastructure. Exact dependency versions will be pinned when each project is scaffolded and recorded by the lockfiles.

## Backend

| Concern | Choice | Reason |
|---|---|---|
| Language | Go | Required by the assignment; strong HTTP and concurrency tooling |
| HTTP routing | `chi` | Small, idiomatic router built around `net/http` |
| Database driver | `pgx` | Native Postgres support, transactions, pooling, and good performance |
| Query generation | `sqlc` | Keeps SQL visible while generating type-safe Go access code |
| Migrations | `goose` | Ordered SQL migrations with a small operational surface |
| Password hashing | Argon2id | Memory-hard password hashing with per-password salt |
| Tokens | Signed JWT access tokens plus opaque rotating refresh tokens | Short request authentication plus revocable long-lived sessions |
| Validation | Explicit request/domain validators | Keeps business rules discoverable and testable |
| Logging | Structured JSON using Go's standard structured logger | Searchable production logs without a large dependency |
| Configuration | Environment variables parsed once at startup | Works locally, in CI, and on Railway |
| Tests | Go testing, Postgres integration tests, race detector | Covers domain, persistence, HTTP, and concurrency behavior |

### Why not an ORM?

The assignment is heavily about constraints, transactions, locking, and aggregate queries. Explicit SQL makes those decisions visible in review and avoids accidental ORM behavior. `sqlc` removes routine scanning boilerplate without hiding SQL.

### Backend package boundaries

```text
backend/
├── cmd/api/                 # process entrypoint
├── internal/
│   ├── auth/                # passwords, JWTs, refresh sessions
│   ├── family/              # family, child, invite use cases
│   ├── content/             # masterclass/video reads
│   ├── activity/            # likes, progress, partner aggregation
│   ├── httpapi/             # handlers, middleware, response mapping
│   ├── postgres/            # generated queries and transaction adapters
│   └── platform/            # config, logging, clock, identifiers
├── migrations/
├── queries/
└── testutil/
```

Domain/use-case code must not depend on HTTP types. Handlers authenticate, parse, call a use case, and map typed errors to the API contract.

## Design prototype

| Concern | Choice | Reason |
|---|---|---|
| Location | Root `/prototype` folder | Keeps design validation separate from production Go and Flutter code |
| Runtime | Browser | Fast review on desktop while presenting a constrained mobile viewport |
| Technologies | Semantic HTML, CSS, and vanilla JavaScript | Matches the agreed prototype format and keeps the artifact portable |
| State | Deterministic in-memory/local mock state | Enables two-account and error-state demonstrations without claiming backend behavior |
| Styling | Tokens and components from `design.md` | Gives Flutter one approved visual and interaction reference |
| Assets | Optimized copies of files from `/assets` | Avoids runtime dependency on the public website while preserving originals |

The prototype is not Flutter Web, does not connect to production services, and is not part of the submitted runtime architecture. Business rules must be reimplemented and verified in Go rather than copied from client-side simulation.

## Mobile

| Concern | Choice | Reason |
|---|---|---|
| Framework | Flutter | Required by the assignment and produces the Android APK |
| State/dependency management | Riverpod | Testable state, explicit dependencies, lifecycle support |
| Routing | `go_router` | Declarative auth/onboarding redirects and nested navigation |
| HTTP | Dio | Interceptors, cancellation, timeouts, and coordinated token refresh |
| Models | `freezed` plus JSON serialization | Immutable models and reliable API parsing |
| Secure tokens | `flutter_secure_storage` | Android Keystore-backed secret storage |
| Video | Flutter's maintained `video_player` package | Reusable remote-video playback foundation |
| Sharing | Platform share package | Copy/share invite code through native Android UI |
| Testing | Unit, widget, and integration tests | Covers repositories, controllers, routing, and key screens |

### Mobile package boundaries

```text
mobile/lib/
├── app/                     # app, router, theme, configuration
├── core/                    # networking, errors, secure storage, utilities
├── features/
│   ├── authentication/
│   ├── onboarding/
│   ├── family/
│   ├── library/
│   └── player/
└── shared/                  # reusable widgets and domain primitives
```

Each feature separates data sources, repositories, application state, and presentation. The video player is a reusable component; masterclass screens do not own low-level playback logic.

## Hosted services

| Service | Use |
|---|---|
| Railway | Persistent Go API process and public HTTPS URL |
| Supabase Postgres | Primary relational database |
| Supabase Storage | Public, read-only demo video and thumbnail objects |
| GitHub | Repository and CI |

Supabase Auth, PostgREST, Edge Functions, and Realtime are not used by the mobile app. All application reads and writes go through Go.

## Developer tooling

- Root `Makefile` or equivalent documented commands for common tasks.
- `golangci-lint` configuration with a focused, non-noisy ruleset.
- `dart format`, `flutter analyze`, and `flutter test` in CI.
- Docker Compose for a local Postgres dependency only; the application remains runnable without Docker when a database URL is supplied.
- Seed command that is explicit and safe to rerun.
- No generated secrets or checked-in `.env` files.

## Alternatives considered

- **Vercel Go functions:** possible but introduces serverless handler and database-pool constraints; rejected for a conventional backend demonstration.
- **Render free:** easy Go deployment but cold starts can disrupt a live demo; retained as fallback.
- **Supabase Auth:** faster, but would move an explicitly chosen learning and assessment area out of Go.
- **GORM:** productive CRUD, but less transparent for this transaction-heavy slice.
- **WebSockets/Supabase Realtime:** unnecessary because refresh consistency is accepted.
- **BLoC:** valid, but Riverpod offers less ceremony for the project size.

## Version policy

Use a stable, mutually compatible Go toolchain, Flutter stable channel, Android SDK, and package versions at scaffold time. Do not use floating dependency constraints in the submitted project. Record build prerequisites in the root README.
