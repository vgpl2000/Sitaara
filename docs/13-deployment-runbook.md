# Deployment Runbook

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Target topology

- Go API: Railway public service.
- Database: Supabase Postgres.
- Media: Supabase Storage public bucket containing licensed demo assets only.
- Client: signed or clearly marked release Android APK distributed directly.
- Repository/CI: GitHub.

## Required accounts

- GitHub repository owner access.
- Supabase project owner access.
- Railway project owner access connected to GitHub.
- Android release signing key under the author's control.

Do not share provider passwords or tokens in chat, source code, screenshots, or documentation.

## Environment variables

| Name | Purpose | Secret |
|---|---|---|
| `APP_ENV` | `local`, `test`, or `production` | No |
| `PORT` | Injected HTTP port | No |
| `DATABASE_URL` | TLS Postgres/pooler connection string | Yes |
| `JWT_SECRET` | Access-token signing secret | Yes |
| `JWT_ISSUER` | Expected issuer | No |
| `JWT_AUDIENCE` | Expected audience | No |
| `INVITE_HMAC_SECRET` | Keyed invite digest secret | Yes |
| `REFRESH_HMAC_SECRET` | Keyed refresh-token digest secret | Yes |
| `ACCESS_TOKEN_TTL` | Proposed `15m` | No |
| `REFRESH_TOKEN_TTL` | Proposed `720h` | No |
| `LOG_LEVEL` | Structured log level | No |
| `DB_MAX_CONNECTIONS` | Bounded application pool | No |
| `STORAGE_PUBLIC_BASE_URL` | Public media base | No |

Secrets must be distinct high-entropy values. Production startup fails closed when required configuration is missing or unsafe.

## Supabase setup

1. Create a project in a nearby region.
2. Record the database pooler connection appropriate for the Railway network and require TLS.
3. Create a public bucket dedicated to non-private demo media.
4. Upload optimized MP4s and thumbnails using stable object names.
5. Verify anonymous GET access only to the intended bucket.
6. Do not expose Supabase service-role credentials to Flutter.
7. Apply migrations through controlled backend tooling, not manual table editing.
8. Run idempotent content/demo seed.

Use conservative Go pool settings. Validate the effective Supabase connection limit before increasing them.

## Railway setup

1. Create a project and service from the GitHub repository.
2. Set the root/build context to `backend` if the monorepo requires it.
3. Build a static or normal Go binary using the pinned module.
4. Start the binary; it must bind to Railway's `PORT` on all interfaces.
5. Add environment variables in Railway's secret/configuration UI.
6. Configure `/healthz` as liveness and `/readyz` where dependency readiness is supported.
7. Generate the public HTTPS domain.
8. Confirm logs contain startup metadata but no secret values.

The API should not run migrations concurrently in every process startup. For the single-instance demo, use a controlled deployment/release step or manually invoke the versioned migration command immediately before application rollout.

## Database migration procedure

1. Back up or confirm recoverability before risky changes.
2. Run migration status against the target.
3. Apply pending migrations once.
4. Verify expected schema version.
5. Deploy compatible API.
6. Check readiness and smoke tests.

Prefer backward-compatible expand/deploy/contract changes even though the assignment uses one service instance.

## Seeding procedure

- Content seed uses stable IDs/slugs and upserts metadata intentionally.
- Demo account seed is explicit, idempotent, and disabled unless requested by command/config.
- Demo seed never overwrites arbitrary registered users.
- Passwords for intentionally public demo accounts are created via the same hashing function as registration.
- Seed output does not print password hashes, session tokens, or invite codes.

## APK configuration and build

1. Supply production API URL using a compile-time Dart definition or production flavor.
2. Ensure Android internet permission is present.
3. Permit HTTPS only; no cleartext production traffic.
4. Build release APK with the controlled keystore.
5. Record application ID, version name, version code, Git commit, and API environment.
6. Install on a clean Android device/emulator.
7. Complete the release checklist in `12-testing-strategy.md`.
8. Publish APK checksum with the submission if practical.

No database credentials, JWT signing keys, invite digest keys, or Supabase service keys belong in Dart defines.

## Smoke tests after deploy

1. `/healthz` returns 200.
2. `/readyz` returns 200.
3. Register and login work.
4. Seeded content returns two masterclasses.
5. Seeded accounts log in and show partner activity.
6. Create/join a temporary family and verify shared activity.
7. Check Railway error logs and database connection usage.

## Rollback

- Application: redeploy the last known-good Railway build.
- Database: prefer a forward corrective migration. Use down migration only when verified safe and no newer data depends on it.
- APK: retain the prior artifact and version; server contract remains backward compatible during handoff.
- Media: use versioned/stable object names so rollback does not point at overwritten incompatible files.

## Operational notes

- Railway trial/free credits and service policy can change; verify project availability before submission.
- Add a simple warm-up check before the live demonstration.
- Monitor unexpected 5xx responses, readiness failures, connection exhaustion, and repeated authentication/invite failures.
- The demo contains no real child or parent information.
