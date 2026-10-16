# Sitaara Partner Linking and Shared Progress

An assignment prototype for a Flutter Android application backed by a Go API and PostgreSQL. Two parents link around one child and can view one another's likes and video progress.

## Current status

- Product, architecture, security, API, and delivery plans are documented in [`docs/`](docs/README.md).
- The approved HTML/CSS/JavaScript design reference lives in [`prototype/`](prototype/README.md).
- The implementation tracker is [`docs/18-implementation-checklist.md`](docs/18-implementation-checklist.md).
- Phase 1 of the production Go backend is implemented locally and awaiting its first hosted CI run.
- Flutter implementation begins in Phase 5 after the API domain phases are complete.

## Planned repository layout

```text
Sitaara/
├── assets/       # supplied source brand assets
├── backend/      # Go API; Railway service root
├── docs/         # canonical requirements and implementation tracker
├── mobile/       # Flutter Android application (created in Phase 5)
└── prototype/    # approved standalone design prototype
```

## Verified development toolchain

| Tool | Version/configuration |
|---|---|
| Go | 1.27.0, Windows amd64 |
| PostgreSQL | 17.11, local automatic Windows service |
| Flutter | 3.47.7 stable |
| Dart | 3.13.5 |
| Java | Microsoft OpenJDK 17.0.20.1 LTS |
| Android SDK | Platform 36 and build-tools 36.0.0 |
| Android minimum | API 24, matching Flutter 3.47's supported floor |

The generated local PostgreSQL password is stored outside the repository in the user-scoped `SITAARA_LOCAL_POSTGRES_PASSWORD` environment variable. Open a new terminal after setup changes so it receives the updated `PATH`, `JAVA_HOME`, and Android SDK variables.

## Architecture

- Flutter Android application communicates only with the Go JSON API.
- Go owns authentication, authorization, partner linking, likes, and progress.
- Supabase provides hosted PostgreSQL for the deployed environment.
- Cloudinary delivers licensed, non-sensitive demo media.
- Railway builds and hosts the Go service from `/backend`.

## Local configuration

Use [`backend/.env.example`](backend/.env.example) as the Phase 1 variable reference and supply values through the environment. Construct `DATABASE_URL` using the locally stored PostgreSQL credential. Never put production or provider credentials in the repository or APK.

Backend setup and runnable commands are documented in [`backend/README.md`](backend/README.md). Mobile commands will be added with the Phase 5 Flutter scaffold.

## Railway

Create the Railway backend service from this GitHub repository and configure its root directory as `/backend`. Railway will build the checked-in backend `Dockerfile`. Health checks use `/healthz`; readiness uses `/readyz` where supported.

See [`backend/README.md`](backend/README.md) and [`docs/13-deployment-runbook.md`](docs/13-deployment-runbook.md) for the planned deployment boundary.
