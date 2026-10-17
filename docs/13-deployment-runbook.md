# Deployment Runbook

**Status:** Implemented; hosted runbook in use
**Last updated:** 2026-10-16  

## Target topology

- Go API: Railway public service.
- Database: Supabase Postgres.
- Media: Cloudinary public delivery containing licensed demo assets only.
- Client: locally signed release Android APK distributed directly.
- Repository/CI: GitHub.

## Required accounts

- GitHub repository owner access.
- Supabase project owner access.
- Cloudinary account access with a project-specific product environment/folder.
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

Secrets must be distinct high-entropy values. Production startup fails closed when required configuration is missing or unsafe.

## Supabase setup

1. Create a project in a nearby region.
2. Copy the Supabase Session pooler connection string on port `5432`, replace its password placeholder, and require TLS. Do not use the IPv6-only direct hostname unless Railway outbound IPv6 has explicitly been enabled.
3. Do not enable or depend on Supabase Storage for this project.
4. Do not expose Supabase database or service-role credentials to Flutter.
5. Apply migrations through controlled backend tooling, not manual table editing.
6. Run the idempotent content/demo seed after Cloudinary asset metadata is ready.

Use conservative Go pool settings. Validate the effective Supabase connection limit before increasing them.

## Cloudinary setup

1. Create or select a Cloudinary product environment dedicated to the assignment.
2. Keep `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, and `CLOUDINARY_API_SECRET` in the trusted upload environment only. The API secret never enters Git, Flutter, or the runtime Railway service.
3. Upload the processed H.264/AAC MP4 files and thumbnails under stable project-owned public IDs, for example `sitaara/masterclasses/<masterclass>/<video>`.
4. Use public delivery only because the assets are licensed and non-sensitive. User-generated or family-private media is not uploaded.
5. Record each media public ID, thumbnail public ID, HTTPS delivery URL, duration, and licence-manifest entry.
6. Verify every delivery URL anonymously from a clean browser/device and confirm Android playback before seeding the database.
7. Centralize any delivery transformation in seed/deployment configuration. Flutter treats URLs as opaque and does not generate arbitrary transformation paths.

The runtime Go API does not require a Cloudinary SDK or write credential for this release. Uploading is an explicit content-operations step, not a mobile or public API feature.

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
- The assignment seed explicitly runs through the `seed` command and is idempotent; normal API startup never seeds data.
- Demo seed only upserts its stable assignment-owned UUIDs and email addresses; it never targets arbitrary registered users.
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

No database credentials, JWT signing keys, invite digest keys, Supabase service keys, or Cloudinary API credentials belong in Dart defines.

## Smoke tests after deploy

1. `/healthz` returns 200.
2. `/readyz` returns 200.
3. Register and login work.
4. Seeded content returns two masterclasses.
5. Seeded accounts log in and show partner activity.
6. Create/join a temporary family and verify shared activity.
7. Check Railway error logs and database connection usage.
8. Open every seeded Cloudinary thumbnail and play at least one video on the target Android device/network.

## Rollback

- Application: redeploy the last known-good Railway build.
- Database: prefer a forward corrective migration. Use down migration only when verified safe and no newer data depends on it.
- APK: retain the prior artifact and version; server contract remains backward compatible during handoff.
- Media: use stable public IDs plus versioned delivery URLs; keep the previous Cloudinary asset/version available until the rollback window closes.

## Operational notes

- Railway trial/free credits and service policy can change; verify project availability before submission.
- Cloudinary plan limits and delivery behavior can change; verify the active account limits and all seeded assets before submission.
- Add a simple warm-up check before the live demonstration.
- Monitor unexpected 5xx responses, readiness failures, connection exhaustion, and repeated authentication/invite failures.
- The demo contains no real child or parent information.
