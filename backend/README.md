# Sitaara Go API

This directory is the deployable Railway service root. Phase 1 provides a production-shaped Go API foundation with typed configuration, structured logs, PostgreSQL pooling, controlled migrations, generated queries, health checks, tests, and graceful shutdown.

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

## Development commands

Run `.\scripts\dev.ps1 <action>` from this directory. Supported actions are `format`, `lint`, `test`, `test-integration`, `generate`, `migrate-up`, `migrate-status`, and `run`. The `seed` action is intentionally reserved until the Phase 4 content model exists.

Integration tests require `TEST_DATABASE_URL`. Query generation uses the pinned sqlc version declared in the script and CI.

## Configuration

| Variable | Secret | Required now | Purpose |
|---|---:|---:|---|
| `APP_ENV` | No | No | `local`, `test`, or `production`; defaults to `local`. |
| `PORT` | No | No | HTTP port; Railway injects it in production. |
| `DATABASE_URL` | Yes | Yes | PostgreSQL connection URL. Production rejects non-TLS URLs. |
| `LOG_LEVEL` | No | No | `debug`, `info`, `warn`, or `error`. |
| `DB_MAX_CONNECTIONS` | No | No | Conservative pool limit; defaults to `5`. |

Authentication secrets are deliberately not consumed yet. Phase 2 will add and validate them when authentication is implemented.

## Railway

Configure the Railway service root as `/backend`. Railway will build the checked-in `Dockerfile`; the runtime image is non-root and contains the API binary, migration binary, and migration files. Configure `/app/sitaara-migrate up` as the controlled pre-deploy migration command rather than migrating during API startup.

Never place Cloudinary upload credentials, JWT signing material, invite/refresh secrets, Android signing material, or a real database URL in this directory.
