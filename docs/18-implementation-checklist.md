# Living Implementation Checklist

**Status:** Active  
**Last updated:** 2026-10-16  
**Current phase:** Phase 6 library and video experience in progress

**Next phase:** Phase 7 - Media, seed, and hosted release verification

**Next milestone:** Finish the player polish and verify onboarding/content on Android after the Windows loopback restart

## Purpose

This is the day-to-day execution tracker for the Sitaara assignment. The numbered planning documents define what the system must do; this checklist records whether that work has been implemented and verified.

Do not treat a checked documentation task as proof that the corresponding code exists. An implementation item is complete only when its stated evidence exists.

## How to maintain this checklist

- Use `[ ]` for not started or incomplete work and `[x]` only for verified work.
- Keep only one phase marked **In progress** unless parallel work is intentional and documented.
- Add a short entry to the phase evidence section when completing a meaningful group of tasks.
- Reference the relevant commit, pull request, test command, screenshot, APK, or deployed URL where practical.
- If implementation changes a contract, update the canonical document and, for a major decision, add or supersede an ADR before checking the task.
- Never add secrets, passwords, tokens, connection strings, private signing material, or raw invite codes as evidence.
- Reopen a checked task if later changes invalidate its verification.

## Status summary

| Phase | Status | Exit gate |
|---|---|---|
| 0. Contracts and repository readiness | Ready for foundation work; final document approval sweep pending | Contracts approved and toolchain/repository conventions recorded |
| 0A. HTML design prototype | Approved; baseline capture pending | Approved mobile reference exists separately from Flutter |
| 1. Backend foundation | Implemented locally; hosted CI pending | API builds, migrates, tests, and reports health/readiness |
| 2. Schema and authentication | Implemented locally; hosted race/CI pending | Registration, login, refresh, logout, and `/v1/me` work safely |
| 3. Family, child, and partner linking | Implemented locally; hosted race/CI pending | Linking invariants survive invalid and concurrent requests |
| 4. Content and shared activity | Implemented locally; hosted race/CI pending | API supports the complete assignment story without Flutter |
| 5. Flutter foundation and onboarding | Foundation implemented; device/two-session verification pending | Two app sessions can register, create, invite, and join |
| 6. Library and video experience | In progress; core screens and activity mutations implemented | Full mobile experience works against the local API |
| 7. Media, seed, and hosted environment | Pulled-forward hosting/media tasks partially complete | Clean release APK works with Railway, Supabase, and Cloudinary |
| 8. Final verification and submission | Not started | Reviewer can install and demonstrate the project unaided |

## Phase 0 - Contracts and repository readiness

**Status:** Ready for implementation; final approval sweep pending  
**Depends on:** None  
**Canonical references:** `README.md`, `01-assignment-analysis.md` through `17-ai-usage-and-verification.md`, and `decisions/`

### Product and technical decisions

- [x] `P0-01` Extract the supplied assignment requirements and planned proof.
- [x] `P0-02` Define the product scope, exclusions, user flows, and acceptance criteria.
- [x] `P0-03` Define the mobile screen specification and design system.
- [x] `P0-04` Define the Go/Flutter technical stack and component boundaries.
- [x] `P0-05` Define the database model, constraints, indexes, and transaction boundaries.
- [x] `P0-06` Define the HTTP API contract and public error model.
- [x] `P0-07` Define authentication, authorization, invite, and token security policies.
- [x] `P0-08` Define testing, deployment, demo-data, risk, and AI-verification plans.
- [x] `P0-09` Record the move from Supabase Storage to Cloudinary in ADR-007.
- [ ] `P0-10` Perform the final pre-code review of all documents and change their status from Draft to Approved where appropriate.

### Repository and local toolchain

- [x] `P0-11` Confirm the Git repository and `origin` remote.
- [x] `P0-12` Add or verify root ignore rules for Go, Flutter, IDE, environment, signing, coverage, and generated artifacts.
- [x] `P0-13` Add a root README skeleton with project purpose, architecture summary, and placeholder run commands.
- [x] `P0-14` Add safe environment examples containing names/descriptions only.
- [x] `P0-15` Record the selected Go version.
- [x] `P0-16` Record the Flutter stable and Dart versions.
- [x] `P0-17` Record the Android SDK/minimum SDK targets.
- [x] `P0-18` Confirm local Postgres or Docker availability for integration tests.
- [x] `P0-19` Decide and document the common root commands (`Makefile`, scripts, or equivalent).
- [x] `P0-20` Confirm no credentials or generated secrets are already tracked.

### Exit gate

- [ ] No unresolved product or architecture question blocks the schema or API foundation.
- [x] All required local tools report usable versions.
- [x] A new contributor can identify where backend, mobile, prototype, assets, and docs belong.

### Evidence

- Documentation set: `docs/`
- Git remote confirmed: `origin` points to the Sitaara repository.
- Toolchain verified: Go 1.27.0, PostgreSQL 17.11, Flutter 3.47.7, Dart 3.13.5, OpenJDK 17, and Android SDK 36 with accepted licences.
- Repository readiness: root ignore/environment/README files and the tracked Railway `/backend` service root are present.
- Common backend commands: `backend/scripts/dev.ps1`, documented in `backend/README.md`.
- Pending: final documentation approval sweep.

## Phase 0A - Mobile experience prototype

**Status:** Approved; baseline capture pending  
**Depends on:** Product flows and design system  
**Canonical references:** `design.md`, `05-mobile-screen-specification.md`, and `/prototype/README.md`

### Build and review

- [x] `P0A-01` Create the separate root `/prototype` folder.
- [x] `P0A-02` Build the prototype with semantic HTML, CSS, and vanilla JavaScript.
- [x] `P0A-03` Use optimized local copies of the supplied Sitaara assets.
- [x] `P0A-04` Apply primary purple `#462E91` and logo/accent green `#8AC340`.
- [x] `P0A-05` Represent authentication and onboarding flows.
- [x] `P0A-06` Represent create-child, invite, and join-family flows.
- [x] `P0A-07` Represent masterclasses, partner activity, likes, and progress.
- [x] `P0A-08` Include representative loading, empty, success, and error feedback.
- [x] `P0A-09` Run the prototype locally in a constrained mobile viewport.
- [x] `P0A-10` Receive project-author approval of the overall prototype design.
- [ ] `P0A-11` Capture the final approved reference screens or commit identifier before Flutter translation begins.

### Exit gate

- [x] The prototype is visually approved as the Flutter reference.
- [x] The prototype remains clearly separate from the production mobile architecture.
- [ ] Final baseline evidence is recorded before Phase 5 UI implementation.

### Evidence

- Prototype entry point: `/prototype/index.html`
- Supporting files: `/prototype/styles.css`, `/prototype/app.js`, and `/prototype/validate.mjs`
- Reviewed locally at `http://127.0.0.1:4173/` in a mobile viewport.

## Phase 1 - Backend foundation

**Status:** Implemented locally; hosted CI pending

**Depends on:** Phase 0 architecture and toolchain decisions  
**Canonical references:** `06-technical-stack.md`, `07-system-architecture.md`, `12-testing-strategy.md`

### Project scaffold

- [x] `P1-01` Create `backend/` with a Go module and pinned Go version.
- [x] `P1-02` Create `cmd/api` and the agreed `internal/` package boundaries.
- [x] `P1-03` Add a minimal application entry point with clean startup/shutdown.
- [x] `P1-04` Add focused commands for format, lint, test, integration test, migration, generation, and run; reserve seed until its Phase 4 model exists.
- [x] `P1-05` Add `.env.example` with safe placeholders and descriptions.
- [x] `P1-06` Ensure local secrets and binaries are ignored.

### Configuration and platform behavior

- [x] `P1-07` Parse configuration once at startup into typed values.
- [x] `P1-08` Reject missing or unsafe production configuration.
- [x] `P1-09` Add structured JSON logging with environment, service version, and request ID.
- [x] `P1-10` Redact secrets and sensitive request data from logs.
- [x] `P1-11` Add panic recovery and centralized safe error responses.
- [x] `P1-12` Configure HTTP read, write, idle, and graceful-shutdown timeouts.
- [x] `P1-13` Add request-body size limits.
- [x] `P1-14` Implement `/healthz` without dependency checks.
- [x] `P1-15` Implement `/readyz` with a bounded database ping.

### Postgres and migrations

- [x] `P1-16` Add `pgx` connection-pool setup using `DATABASE_URL` and TLS configuration.
- [x] `P1-17` Set conservative configurable connection limits and timeouts.
- [x] `P1-18` Add `goose` migration tooling and an empty/initial migration path.
- [x] `P1-19` Add `sqlc` configuration and query-generation command.
- [x] `P1-20` Verify migrations apply from zero and report their version.
- [x] `P1-21` Verify application shutdown closes the HTTP server and database pool cleanly.

### Automated verification

- [x] `P1-22` Add unit-test structure and reusable test helpers.
- [x] `P1-23` Add an integration-test Postgres environment.
- [x] `P1-24` Test configuration validation and production fail-closed behavior.
- [x] `P1-25` Test liveness and readiness success/failure behavior.
- [x] `P1-26` Add CI steps for formatting, vet/static analysis, migrations, tests, and API build.
- [x] `P1-27` Confirm CI does not require production credentials.

### Exit gate

- [x] A clean checkout can start Postgres, apply migrations, and run the API using documented commands.
- [x] `/healthz` returns 200 while the process is alive.
- [x] `/readyz` reflects database availability with a bounded timeout.
- [ ] CI builds and tests the empty service successfully.
- [x] Logs contain request IDs and no secrets.

### Evidence

- Commit/PR: local working tree; not committed or pushed yet.
- Commands run: Go format, unit tests, vet, API/migration builds, sqlc generation, Goose migration up/status, integration tests, and local endpoint smoke checks.
- Test result: local unit/integration/build/migration/API checks pass on 2026-10-16. Hosted CI remains pending.

## Phase 2 - Schema and authentication

**Status:** Implemented locally; hosted race/CI pending
**Depends on:** Phase 1  
**Canonical references:** `08-data-model.md`, `09-api-contract.md`, `10-authentication-and-security.md`

### Database schema

- [x] `P2-01` Add required Postgres extensions, including case-insensitive email support.
- [x] `P2-02` Create `users` with UUIDs, normalized unique email, password hash, and timestamps.
- [x] `P2-03` Create `refresh_sessions` with digests, rotation-family fields, expiry, use, and revocation timestamps.
- [x] `P2-04` Add foreign keys, uniqueness constraints, and session lookup indexes.
- [x] `P2-05` Generate and review typed `sqlc` queries.
- [x] `P2-06` Prove the schema migrates both an empty database and the previous migration version.

### Password and session primitives

- [x] `P2-07` Implement Argon2id hashing with explicit parameters and per-password salt.
- [x] `P2-08` Implement constant-time password verification and transparent parameter inspection.
- [x] `P2-09` Enforce password length before hashing and apply request-size limits.
- [x] `P2-10` Implement signed JWT access tokens with issuer, audience, subject, issued-at, and expiry validation.
- [x] `P2-11` Implement high-entropy opaque refresh tokens.
- [x] `P2-12` Store only keyed/digested refresh-token material.
- [x] `P2-13` Implement transactional refresh rotation.
- [x] `P2-14` Revoke a rotation family when a consumed token is reused.

### HTTP operations

- [x] `P2-15` Implement `POST /v1/auth/register`.
- [x] `P2-16` Implement `POST /v1/auth/login` with non-enumerating invalid-credential errors.
- [x] `P2-17` Implement `POST /v1/auth/refresh`.
- [x] `P2-18` Implement idempotent `POST /v1/auth/logout`.
- [x] `P2-19` Implement bearer-token authentication middleware.
- [x] `P2-20` Implement `GET /v1/me` with onboarding state.
- [x] `P2-21` Add stricter rate limits for register, login, and refresh operations.
- [x] `P2-22` Reject unknown JSON fields and malformed/oversized bodies consistently.

### Verification

- [x] `P2-23` Unit-test password, token, expiry, issuer, and audience behavior.
- [x] `P2-24` Integration-test registration, duplicate normalized email, login, logout, and `/v1/me`.
- [x] `P2-25` Test concurrent refresh so only an allowed rotation outcome succeeds.
- [x] `P2-26` Test consumed-token reuse and rotation-family revocation.
- [x] `P2-27` Verify errors and logs contain no password, JWT, refresh token, or digest.
- [ ] `P2-28` Run targeted Go race tests.

### Exit gate

- [x] Auth sessions work through the published HTTP contract.
- [x] Database contents do not reveal raw passwords or refresh tokens.
- [x] Concurrent refresh and replay behavior is executable and documented.

### Evidence

- Commit/PR: local working tree; not committed or pushed yet.
- Migration version: `00002_users_and_refresh_sessions.sql`; verified both from version 1 and from an empty disposable database.
- Tests: unit and PostgreSQL integration suites pass, including HTTP auth lifecycle and concurrent refresh/reuse revocation. Local live API smoke test passed register, `/v1/me`, refresh, and logout. Race execution is configured in CI and remains pending there because the Windows toolchain has CGO disabled.

## Phase 3 - Family, child, and partner linking

**Status:** Implemented locally; hosted race/CI pending
**Depends on:** Phase 2  
**Canonical references:** `04-user-stories-and-acceptance.md`, `08-data-model.md`, `11-domain-rules-and-edge-cases.md`

### Schema and domain policies

- [x] `P3-01` Create families, family members, children, and partner-invite tables.
- [x] `P3-02` Enforce one family per account.
- [x] `P3-03` Enforce one child per family.
- [x] `P3-04` Enforce at most one Mom and one Dad per family.
- [x] `P3-05` Validate child name and date of birth using the service clock.
- [x] `P3-06` Implement unambiguous six-character invite generation.
- [x] `P3-07` Store only HMAC/keyed invite-code digests.
- [x] `P3-08` Enforce 24-hour expiry, single use, revocation, and active-invite replacement.

### Use cases and endpoints

- [x] `P3-09` Implement atomic family/member/child creation.
- [x] `P3-10` Implement `POST /v1/families`.
- [x] `P3-11` Implement `GET /v1/family` without accepting a client family ID.
- [x] `P3-12` Implement invite creation and return the raw code once.
- [x] `P3-13` Implement transactional invite redemption with row locking.
- [x] `P3-14` Derive the joining role safely and reject an occupied/same role.
- [x] `P3-15` Prevent self-linking and cross-family reassignment.
- [x] `P3-16` Map invalid, expired, used, role-taken, and family-full outcomes to the API contract.
- [x] `P3-17` Return the updated onboarding/family state from `/v1/me`.
- [x] `P3-18` Apply rate limiting to invite redemption.

### Verification

- [x] `P3-19` Test successful creator and partner flows.
- [x] `P3-20` Test invalid/malformed, expired, revoked, and already-used codes.
- [x] `P3-21` Test self-link, wrong role, existing family, and full-family rejection.
- [x] `P3-22` Race two accounts against one invite and prove exactly one wins.
- [x] `P3-23` Race duplicate family creation for one account.
- [x] `P3-24` Test unrelated-family access and ID substitution attempts.
- [x] `P3-25` Verify invite codes and child/family identifiers do not leak in logs or unsafe errors.

### Exit gate

- [x] Exactly one concurrent invite redemption succeeds.
- [x] Database constraints remain decisive when application checks race.
- [x] No endpoint lets a caller select or inspect another family.

### Evidence

- Commit/PR: local working tree; not committed or pushed yet.
- Concurrency test: synchronized two-user invite redemption and duplicate family creation pass against PostgreSQL.
- Authorization test: family identity is always derived from the authenticated user; unrelated-family partner activity remains absent.

## Phase 4 - Content and shared activity

**Status:** Implemented locally; hosted race/CI pending
**Depends on:** Phase 3 and prepared seed metadata  
**Canonical references:** `08-data-model.md`, `09-api-contract.md`, `11-domain-rules-and-edge-cases.md`, `14-demo-data-and-content.md`

### Content schema and seed

- [x] `P4-01` Create masterclass and video tables with ordering and publication constraints.
- [x] `P4-02` Store Cloudinary public IDs and HTTPS delivery URLs for media/thumbnails.
- [x] `P4-03` Create likes with a composite uniqueness constraint.
- [x] `P4-04` Create progress with furthest position, recency, completion, and supporting indexes.
- [x] `P4-05` Implement an idempotent content seed using stable IDs/slugs.
- [x] `P4-06` Validate two masterclasses with four and five ordered videos and positive canonical durations.

### Read models

- [x] `P4-07` Implement ordered `GET /v1/masterclasses`.
- [x] `P4-08` Implement `GET /v1/masterclasses/{id}`.
- [x] `P4-09` Implement `GET /v1/videos/{id}`.
- [x] `P4-10` Return own likes, progress, completion, and aggregates.
- [x] `P4-11` Resolve the partner exclusively through authenticated family membership.
- [x] `P4-12` Return partner status without partner email or internal identifiers.
- [x] `P4-13` Calculate duration-weighted masterclass progress.
- [x] `P4-14` Calculate current-watching state using the agreed 10-minute window.
- [x] `P4-15` Avoid per-video N+1 queries.

### Mutations

- [x] `P4-16` Implement idempotent like using desired-state `PUT`.
- [x] `P4-17` Implement idempotent unlike using desired-state `DELETE`.
- [x] `P4-18` Implement atomic monotonic progress upsert using `greatest`.
- [x] `P4-19` Clamp progress to canonical duration.
- [x] `P4-20` Set completion once at the 90% threshold and never clear it.
- [x] `P4-21` Update valid recency even when furthest progress does not increase.

### Verification

- [x] `P4-22` Test duplicate/concurrent likes and unlike retries.
- [x] `P4-23` Test out-of-order and concurrent progress writes.
- [x] `P4-24` Test exact 90% boundary and excessive-position clamping.
- [x] `P4-25` Test weighted aggregation with unequal video durations.
- [x] `P4-26` Test current-watching boundary and completed-video exclusion.
- [x] `P4-27` Test unlinked, linked, and unrelated-family read models.
- [x] `P4-28` Measure/query-test the fixed read-query shape.
- [x] `P4-29` Complete an API-only end-to-end scenario for two accounts.

### Exit gate

- [x] The API alone supports registration, linking, content, likes, progress, and partner visibility.
- [x] Concurrency cannot decrease progress or create duplicate likes.
- [x] Cross-family activity remains inaccessible.

### Evidence

- Commit/PR: local working tree; not committed or pushed yet.
- API scenario: in-process HTTP scenario passes registration, family creation, invite linking, likes, progress, and partner visibility.
- Aggregate/concurrency tests: PostgreSQL tests pass duplicate/concurrent likes, out-of-order/concurrent progress, threshold/clamping, weighted aggregates, and cross-family isolation.

## Phase 5 - Flutter foundation and onboarding

**Status:** Foundation implemented; verification pending  
**Depends on:** Phase 4 API contract and approved prototype baseline  
**Canonical references:** `05-mobile-screen-specification.md`, `design.md`, `09-api-contract.md`

### Mobile scaffold

- [x] `P5-01` Create `mobile/` using the pinned Flutter stable toolchain.
- [x] `P5-02` Set application ID, minimum Android SDK, versioning, and internet permission.
- [x] `P5-03` Add Riverpod, `go_router`, Dio, model generation, secure storage, and test dependencies.
- [x] `P5-04` Create the agreed feature-oriented package structure.
- [x] `P5-05` Add local and production API-base configuration without secrets.
- [x] `P5-06` Recreate design tokens, typography, spacing, shapes, and semantic colors in Flutter.
- [x] `P5-07` Import optimized logo/app-icon assets with correct sizing.
- [ ] `P5-08` Build shared buttons, fields, cards, feedback, loaders, and error components.

### Networking and session lifecycle

- [x] `P5-09` Implement typed API models and the common response/error envelope.
- [ ] `P5-10` Configure Dio timeouts, safe retry behavior, and request cancellation.
- [x] `P5-11` Store access/refresh tokens in secure storage only.
- [x] `P5-12` Restore sessions on app launch.
- [x] `P5-13` Coordinate refresh so concurrent 401 responses cause one refresh operation.
- [x] `P5-14` Clear session state and route safely after terminal refresh failure.
- [x] `P5-15` Ensure logs/crash messages do not expose tokens or passwords.

### Screens and flows

- [x] `P5-16` Implement Welcome.
- [x] `P5-17` Implement Sign Up with validation and API errors.
- [x] `P5-18` Implement Login with validation and invalid-session recovery.
- [x] `P5-19` Implement onboarding path choice.
- [x] `P5-20` Implement Create Child and role selection.
- [x] `P5-21` Implement Join Family and invite-error states.
- [x] `P5-22` Implement invite display, copy, native share, expiry, and regeneration.
- [x] `P5-23` Implement account summary and logout.
- [x] `P5-24` Implement router redirects for loading, signed-out, needs-family, and onboarded states.

### Verification

- [ ] `P5-25` Unit-test repositories, session restoration, and coordinated refresh.
- [ ] `P5-26` Widget-test forms, loading, validation, and API-error states.
- [ ] `P5-27` Widget-test routing for every onboarding state.
- [x] `P5-28` Run formatter, analyzer, and Flutter tests.
- [ ] `P5-29` Complete the two-session create/invite/join flow against the local API.

### Exit gate

- [ ] Two independent installed app sessions can register and become linked.
- [ ] Tokens persist safely and refresh without duplicate rotations.
- [ ] Flutter matches the approved prototype without embedding its HTML.

### Evidence

- Commit/PR: local working tree; not committed or pushed yet.
- Flutter test/analyze result: `flutter analyze --no-pub` reports no issues; `flutter test --no-pub` passes the welcome/auth-path and coordinated-refresh tests on 2026-10-16.
- Android toolchain: Flutter uses Microsoft OpenJDK 21 and Android launcher variants are generated from the supplied Sitaara icon. Winsock was reset successfully; `ping 127.0.0.1` is healthy, but Java/Gradle still requires a Windows restart before its loopback selector can start and the APK can be assembled.
- Two-session flow: pending against the hosted Railway API.

## Phase 6 - Library and video experience

**Status:** In progress  
**Depends on:** Phase 5  
**Canonical references:** `05-mobile-screen-specification.md`, `design.md`, `12-testing-strategy.md`

### Content experience

- [x] `P6-01` Implement the masterclass library with own and partner summaries.
- [x] `P6-02` Implement masterclass detail with ordered video rows.
- [x] `P6-03` Display not-started, in-progress, completed, liked, and current-watching states clearly.
- [x] `P6-04` Handle an unlinked partner state without broken placeholders.
- [x] `P6-05` Implement pull-to-refresh and refresh-on-entry behavior.
- [x] `P6-06` Implement loading, empty, offline, server-error, and retry states.

### Reusable video player

- [ ] `P6-07` Build a reusable `video_player`-based component.
- [ ] `P6-08` Handle initialization, buffering, seeking, play/pause, completion, and playback failure.
- [x] `P6-09` Send integer progress at a bounded interval.
- [x] `P6-10` Flush progress on pause, route exit, app lifecycle change, and completion where possible.
- [x] `P6-11` Dispose controllers and cancel work safely.
- [x] `P6-12` Keep likes and partner activity usable when video initialization fails.
- [x] `P6-13` Implement like/unlike with optimistic UI and rollback/reconciliation.

### Responsive and accessible quality

- [ ] `P6-14` Verify layouts at 320, 390, and 430 logical-pixel widths.
- [ ] `P6-15` Verify large text does not hide required actions or information.
- [ ] `P6-16` Add semantic labels and adequate touch targets.
- [ ] `P6-17` Verify focus order, keyboard behavior, contrast, and reduced-motion expectations.
- [ ] `P6-18` Avoid relying on color alone for progress, likes, or errors.

### Verification

- [ ] `P6-19` Unit-test progress reporting and optimistic-like recovery.
- [ ] `P6-20` Widget-test all partner/video states and media failure.
- [ ] `P6-21` Verify lower progress from another lifecycle event cannot reduce server state.
- [ ] `P6-22` Run the full local two-account mobile story and refresh partner state.
- [ ] `P6-23` Test on an Android emulator and, if available, a physical Android device.

### Exit gate

- [ ] The complete assignment experience works against the local backend.
- [ ] Playback failures do not block non-media activity.
- [ ] Partner activity converges after entry/refresh as documented.

### Evidence

- Commit/PR: local working tree; not committed or pushed yet.
- Automated checks: formatter and analyzer pass; four Flutter tests pass, including content-model parsing and coordinated token refresh.
- Implemented flow: hosted masterclass list/detail reads, Cloudinary playback, bounded progress reporting, lifecycle flush, and optimistic likes are wired to the protected API.
- Device/emulator: pending; the repaired Windows loopback stack needs one restart before Gradle can assemble and install the APK.
- Accessibility/responsive review: TBD

## Phase 7 - Media, demo seed, and hosted environment

**Status:** Pulled-forward tasks partially complete  
**Depends on:** Phase 4 content schema and Phase 6 player  
**Canonical references:** `13-deployment-runbook.md`, `14-demo-data-and-content.md`, ADR-002, ADR-007

### Licensed media preparation

- [ ] `P7-01` Select nine suitable clips under acceptable reuse terms.
- [ ] `P7-02` Complete the licence manifest for every clip before production seed inclusion.
- [ ] `P7-03` Avoid unapproved Sitaara/Instagram content and unnecessary identifiable children.
- [ ] `P7-04` Process each clip to verified MP4/H.264/AAC with practical 720p bitrate and fast-start metadata.
- [x] `P7-05` Generate consistent representative thumbnails/posters.
- [x] `P7-06` Verify and record exact integer durations.
- [ ] `P7-07` Retain processed source files and provenance outside Cloudinary for migration/recovery.

### Cloudinary

- [x] `P7-08` Create/select the project Cloudinary product environment.
- [x] `P7-09` Configure Cloudinary credentials only in trusted upload tooling.
- [x] `P7-10` Upload assets under stable project-owned public IDs.
- [ ] `P7-11` Record media public ID, thumbnail public ID, delivery URLs, duration, and licence entry. (Technical metadata is complete; licence provenance remains.)
- [x] `P7-12` Verify anonymous HTTPS access to every seeded asset.
- [ ] `P7-13` Verify seeking/range behavior and playback on the target Android player.
- [ ] `P7-14` Confirm no Cloudinary API secret exists in Git, Railway runtime configuration, or the APK.

### Supabase Postgres and Railway

- [ ] `P7-15` Create/select the Supabase project and nearby region.
- [ ] `P7-16` Configure the appropriate TLS pooler connection for Railway.
- [ ] `P7-17` Verify effective connection limits and select a conservative Go pool size.
- [x] `P7-18` Create the Railway project/service from the repository.
- [x] `P7-19` Configure required Railway secrets and non-secret settings.
- [x] `P7-20` Configure health/readiness checks and public HTTPS domain.
- [ ] `P7-21` Apply migrations once through the controlled release procedure.
- [ ] `P7-22` Run the idempotent content and demo-account seed.
- [ ] `P7-23` Confirm startup/runtime logs expose no secrets.

### Release APK and hosted smoke test

- [x] `P7-24` Configure the production API base URL using the release flavor/definition.
- [ ] `P7-25` Create/control Android release-signing material outside Git.
- [ ] `P7-26` Build a signed or clearly marked release APK.
- [ ] `P7-27` Record app ID, version, build number, Git commit, and environment.
- [ ] `P7-28` Install the APK cleanly and confirm HTTPS-only operation.
- [ ] `P7-29` Verify health/readiness, registration, login, linking, content, likes, progress, and refresh.
- [ ] `P7-30` Verify every thumbnail and at least one full video playback/seek on the target network/device.
- [ ] `P7-31` Verify seeded Mom/Dad accounts and a fresh-account flow.
- [ ] `P7-32` Document the rollback path for API, database, APK, and Cloudinary asset versions.

### Exit gate

- [ ] A cleanly installed release APK completes the full flow against hosted services.
- [ ] Supabase is used only for Postgres and Cloudinary only for public demo media.
- [ ] The runtime contains no database, signing, JWT, invite, refresh, or Cloudinary write secrets.

### Evidence

- Railway URL/health result: `https://sitaara-production.up.railway.app`; `/healthz` returned HTTP 200 `ok` and `/readyz` returned HTTP 200 `ready` on 2026-10-16.
- Supabase migration version: TBD
- Cloudinary asset verification: 9/9 videos and generated posters returned HTTPS 200 on 2026-10-16; MP4 byte-range delivery confirmed.
- APK path/version: TBD

## Phase 8 - Final verification and submission

**Status:** Not started  
**Depends on:** All prior phases  
**Canonical references:** `12-testing-strategy.md`, `13-deployment-runbook.md`, `16-risks-and-tradeoffs.md`, `17-ai-usage-and-verification.md`

### Automated quality gates

- [ ] `P8-01` Run all Go unit and integration tests from a clean state.
- [ ] `P8-02` Run targeted race/concurrency tests.
- [ ] `P8-03` Apply all migrations to an empty Postgres database.
- [ ] `P8-04` Run Go formatting, vet/static analysis, and production build.
- [ ] `P8-05` Run Dart format, Flutter analyze, unit tests, and widget tests.
- [ ] `P8-06` Build the final release APK from the recorded commit.
- [ ] `P8-07` Confirm CI passes on the submission commit.

### Security and data-isolation review

- [ ] `P8-08` Inspect tracked files and build configuration for secrets.
- [ ] `P8-09` Inspect logs for passwords, tokens, invite codes, digests, database URLs, and provider secrets.
- [ ] `P8-10` Repeat cross-family IDOR/resource-substitution tests.
- [ ] `P8-11` Repeat invite and refresh concurrency/replay tests.
- [ ] `P8-12` Confirm the APK has no cleartext production traffic or private credentials.
- [ ] `P8-13` Confirm public Cloudinary assets contain no private/user data.

### Manual release scenario

- [ ] `P8-14` Install the final APK on a clean Android environment.
- [ ] `P8-15` Log in to both seeded accounts and verify contrasting activity states.
- [ ] `P8-16` Register two fresh accounts in independent sessions.
- [ ] `P8-17` Create a child, generate an invite, and join as the opposite role.
- [ ] `P8-18` Like and watch content in one account.
- [ ] `P8-19` Refresh the partner account and verify correct shared activity.
- [ ] `P8-20` Exercise invalid invite, offline, server-error, playback-error, and expired-session recovery.
- [ ] `P8-21` Confirm unrelated accounts cannot view or mutate the test family's activity.

### Documentation and handoff

- [ ] `P8-22` Finish the root README with prerequisites, setup, architecture, commands, and demo steps.
- [ ] `P8-23` Publish safe demo credentials and explicitly label them assignment-only.
- [ ] `P8-24` Update every implementation document from Approved to Implemented where evidence exists.
- [ ] `P8-25` Update this checklist and resolve every incomplete release-blocking item.
- [ ] `P8-26` Complete the AI usage, verification, and mistake log honestly.
- [ ] `P8-27` Review risks/trade-offs against the final code and record deviations.
- [ ] `P8-28` Verify ADRs match the final architecture.
- [ ] `P8-29` Confirm repository history is understandable and contains no manufactured commits.
- [ ] `P8-30` Produce and record the APK SHA-256 checksum.
- [ ] `P8-31` Record repository, hosted API, APK, and optional demonstration-video links.
- [ ] `P8-32` Follow the README from a clean environment without relying on undocumented knowledge.

### Exit gate

- [ ] A reviewer can install, log in, create/link accounts, and verify shared activity without assistance.
- [ ] All required automated and manual checks pass on the recorded submission commit.
- [ ] Final artifacts, checksums, URLs, credentials, limitations, and AI disclosure are complete.

### Evidence

- Submission commit: TBD
- CI run: TBD
- APK SHA-256: TBD
- Final manual test date/device: TBD
- Artifact links: TBD

## Deferred work and non-blocking enhancements

These tasks are intentionally excluded from the assignment release unless all required exit gates are complete:

- [ ] Email verification and password recovery.
- [ ] Multi-factor or social authentication.
- [ ] Multiple children, family switching, unlinking, or caregiver replacement.
- [ ] Same-role or configurable caregiver labels beyond the assignment model.
- [ ] Push notifications, WebSockets, or live partner presence.
- [ ] Offline video downloads or full offline mutation synchronization.
- [ ] User-generated/private media and signed Cloudinary delivery.
- [ ] Admin/editor dashboard for content management.
- [ ] iOS distribution or Flutter Web.
- [ ] Optional polished demonstration recording.

## Change log

| Date | Change | Result |
|---|---|---|
| 2026-10-16 | Created the living checklist from the approved prototype and current planning documents | Phase 0 is partially complete, Phase 0A is substantially complete, and Phase 1 is the next implementation focus |
| 2026-10-16 | Completed local toolchain and repository preflight | Installed Go/PostgreSQL, repaired and upgraded Flutter/Android, added safe root files, and created the Railway backend service root |
| 2026-10-16 | Implemented and verified the Phase 1 backend foundation | Added the Go API scaffold, typed configuration, safe logging/middleware, PostgreSQL pool, Goose/sqlc tooling, tests, Railway Dockerfile, and CI workflow; hosted CI remains pending |
| 2026-10-16 | Implemented and locally verified Phase 2 authentication | Added users/sessions schema, Argon2id credentials, JWT access tokens, rotating opaque refresh tokens with replay revocation, auth HTTP operations, strict request handling, throttling, and concurrency/integration tests |
| 2026-10-16 | Implemented and locally verified Phase 3 family linking | Added atomic family/child creation, keyed expiring invites, safe role rules, concurrent redemption protection, HTTP operations, and two-user integration coverage |
| 2026-10-16 | Implemented and locally verified the Phase 4 API | Added content/activity schema, deterministic metadata seed, measured fixed-shape read queries, idempotent likes, monotonic progress, partner views, and API-only end-to-end coverage |
