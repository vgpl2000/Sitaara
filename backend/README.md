# Sitaara Go API

This directory is the deployable Railway service root. The implemented foundation and authentication phases provide typed configuration, structured logs, PostgreSQL pooling, controlled migrations, generated queries, health checks, secure account sessions, tests, and graceful shutdown.

## Prerequisites

- Go 1.27.0
- PostgreSQL 17 (or a compatible hosted PostgreSQL service)
- PowerShell for the convenience script

## Local setup

Set the Phase 1 environment variables in the current terminal. Do not commit their real values:

```powershell
$env:APP_ENV = 'local'
$env:PORT = '8080'
$env:DATABASE_URL = 'postgres://postgres:your_password@127.0.0.1:5432/sitaara?sslmode=disable'
$env:LOG_LEVEL = 'debug'
$env:DB_MAX_CONNECTIONS = '5'
```

Then run:

```powershell
cd backend
.\scripts\dev.ps1 migrate-up
.\scripts\dev.ps1 test
.\scripts\dev.ps1 run
```

The service exposes:

- `GET /healthz` — process liveness; does not call PostgreSQL.
- `GET /readyz` — readiness; performs a bounded PostgreSQL ping.
- `POST /v1/auth/register`, `/login`, `/refresh`, and `/logout` — account and rotating session operations.
- `GET /v1/me` — authenticated account and onboarding state.

## Development commands

Run `.\scripts\dev.ps1 <action>` from this directory. Supported actions are `format`, `lint`, `test`, `test-integration`, `generate`, `migrate-up`, `migrate-status`, `seed`, and `run`. The seed is idempotent and writes stable metadata for two masterclasses containing four and five videos.

Integration tests require `TEST_DATABASE_URL`. Query generation uses the pinned sqlc version declared in the script and CI. The content seed writes two masterclasses containing four and five real Cloudinary videos, using generated video frames for thumbnails.

The convenience script loads the ignored root `.env` file when it exists. Run `.\scripts\init-local-env.ps1` once to replace authentication placeholders with cryptographically random local secrets; existing real secrets are preserved and their values are never printed.

## Configuration

| Variable | Secret | Required now | Purpose |
|---|---:|---:|---|
| `APP_ENV` | No | No | `local`, `test`, or `production`; defaults to `local`. |
| `PORT` | No | No | HTTP port; Railway injects it in production. |
| `DATABASE_URL` | Yes | Yes | PostgreSQL connection URL. Production rejects non-TLS URLs. |
| `LOG_LEVEL` | No | No | `debug`, `info`, `warn`, or `error`. |
| `DB_MAX_CONNECTIONS` | No | No | Conservative pool limit; defaults to `5`. |
| `JWT_SECRET` | Yes | Yes | Signs short-lived access tokens. |
| `JWT_ISSUER` | No | Yes | Expected JWT issuer. |
| `JWT_AUDIENCE` | No | Yes | Expected JWT audience. |
| `INVITE_HMAC_SECRET` | Yes | Yes | Keys stored partner-invite digests. |
| `REFRESH_HMAC_SECRET` | Yes | Yes | Keys stored refresh-token digests. |
| `ACCESS_TOKEN_TTL` | No | No | Access lifetime; defaults to `15m`. |
| `REFRESH_TOKEN_TTL` | No | No | Refresh lifetime; defaults to `720h`. |
| `CLOUDINARY_CLOUD_NAME` | No | Seed only | Builds stable public delivery URLs in the content seed. |

Authentication configuration is required at startup. Use independent, high-entropy values for `JWT_SECRET`, `INVITE_HMAC_SECRET`, and `REFRESH_HMAC_SECRET`; the local initializer replaces placeholders without printing the generated values.

## Railway

Configure the Railway service root as `/backend`. Railway will build the checked-in `Dockerfile`; the runtime image is non-root and contains the API binary, migration binary, and migration files. Configure `/app/sitaara-migrate up` as the controlled pre-deploy migration command rather than migrating during API startup.

Use the TLS-enabled Supabase **Session pooler** URL on port `5432` for `DATABASE_URL`. Supabase direct database hostnames are IPv6-only unless the IPv4 add-on is enabled, while Railway outbound IPv6 is opt-in. The session pooler works over IPv4 and supports the long-lived connections and prepared statements used by this API.

Never place Cloudinary upload credentials, JWT signing material, invite/refresh secrets, Android signing material, or a real database URL in this directory.
