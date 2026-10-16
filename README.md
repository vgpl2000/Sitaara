# Sitaara Partner Linking and Shared Progress

Sitaara is a Flutter Android application backed by a Go API and PostgreSQL. Two parents create separate accounts, link around one child, and share learning progress and likes across two masterclasses containing nine Cloudinary-hosted videos.

## Project status

- The Go API is live at `https://sitaara-production.up.railway.app`.
- The Flutter app uses the hosted HTTPS API by default.
- The approved HTML/CSS/JavaScript reference remains separate in `prototype/`.
- The current debug APK builds successfully; final release signing and full device playback QA remain manual release gates.
- Media licence/provenance fields in `docs/14-demo-data-and-content.md` must be completed before public/reviewer distribution.

The detailed tracker is [`docs/18-implementation-checklist.md`](docs/18-implementation-checklist.md).

## Repository layout

```text
Sitaara/
├── assets/       # original supplied brand assets
├── backend/      # Go API and Railway service root
├── docs/         # requirements, architecture, runbooks, and checklist
├── mobile/       # Flutter Android application
└── prototype/    # approved standalone design reference
```

## Architecture

- Flutter communicates with the Go service for all application JSON operations.
- Go owns authentication, authorization, family linking, invites, likes, and monotonic progress.
- PostgreSQL stores users, families, sessions, catalog metadata, likes, and progress.
- Cloudinary publicly delivers non-sensitive demo videos and posters; no Cloudinary write credential is shipped in the API or APK.
- Railway builds and hosts only the `backend/` service.

## Prerequisites

The verified Windows setup uses Go 1.27, PostgreSQL 17, Flutter 3.47.7 stable, Dart 3.13.5, Microsoft OpenJDK 21, Android SDK 36, and Android minimum SDK 24.

Never commit `.env`, database URLs, JWT/invite/refresh secrets, Cloudinary upload secrets, or Android signing material. Variable names and descriptions are in [`backend/.env.example`](backend/.env.example).

## Run the backend locally

Create a root `.env` with the backend values documented in [`backend/README.md`](backend/README.md), then from PowerShell:

```powershell
backend\scripts\dev.ps1 migrate-up
backend\scripts\dev.ps1 seed
backend\scripts\dev.ps1 test
backend\scripts\dev.ps1 run
```

Health endpoints are `/healthz` and `/readyz`. The API defaults to port 8080 locally when configured accordingly.

## Run the Flutter app

Open `mobile/` in Android Studio, select the connected Android device, and run `lib/main.dart`. No mobile credential is required: the default configuration calls the Railway HTTPS API.

For a local backend, use Android's emulator host mapping and explicitly opt into the local environment:

```powershell
flutter run --dart-define=APP_ENV=local --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Production configuration rejects cleartext or non-local HTTP URLs.

## Verification commands

Backend:

```powershell
backend\scripts\dev.ps1 format
backend\scripts\dev.ps1 lint
backend\scripts\dev.ps1 test
```

Flutter, from `mobile/`:

```powershell
dart format lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

On this `F:` drive checkout, `mobile/android/gradle.properties` disables Kotlin incremental compilation to avoid cross-drive cache errors. If the desktop sandbox gives Java an overlong temporary path, set `TEMP` and `TMP` to a short workspace-local directory for the build process.

The debug APK is generated at `mobile/build/app/outputs/flutter-apk/app-debug.apk`. It is not the final signed submission artifact.

## Demo flow

1. Register the first parent and create a child profile with a Mom or Dad role.
2. Generate and share the one-time invitation code.
3. Register the second parent independently and join with the opposite role.
4. Open either masterclass, play or seek a lesson, and like it.
5. Refresh the partner account and confirm the shared activity appears.

No public seeded Mom/Dad credentials exist yet. Use fresh fictional reviewer accounts until safe assignment-only demo credentials are deliberately created and documented.

## Deployment and rollback

Railway must use `/backend` as the service root and `/app/sitaara-migrate up` as the pre-deploy command. Hosted setup, smoke checks, secret boundaries, rollback procedures, and Cloudinary version handling are documented in [`docs/13-deployment-runbook.md`](docs/13-deployment-runbook.md).
