# Living Implementation Checklist

**Status:** Active  
**Last updated:** 2026-10-16  
**Current phase:** Phase 0 - Contracts and repository readiness  
**Next phase:** Phase 1 - Backend foundation  
**Next milestone:** A locally runnable Go API that migrates Postgres and passes CI

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
| 0. Contracts and repository readiness | In progress | Contracts approved and toolchain/repository conventions recorded |
| 0A. HTML design prototype | Approved; baseline capture pending | Approved mobile reference exists separately from Flutter |
| 1. Backend foundation | Not started | API builds, migrates, tests, and reports health/readiness |
| 2. Schema and authentication | Not started | Registration, login, refresh, logout, and `/v1/me` work safely |
| 3. Family, child, and partner linking | Not started | Linking invariants survive invalid and concurrent requests |
| 4. Content and shared activity | Not started | API supports the complete assignment story without Flutter |
| 5. Flutter foundation and onboarding | Not started | Two app sessions can register, create, invite, and join |
| 6. Library and video experience | Not started | Full mobile experience works against the local API |
| 7. Media, seed, and hosted environment | Not started | Clean release APK works with Railway, Supabase, and Cloudinary |
| 8. Final verification and submission | Not started | Reviewer can install and demonstrate the project unaided |

## Phase 0 - Contracts and repository readiness

**Status:** In progress  
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
- [ ] `P0-12` Add or verify root ignore rules for Go, Flutter, IDE, environment, signing, coverage, and generated artifacts.
- [ ] `P0-13` Add a root README skeleton with project purpose, architecture summary, and placeholder run commands.
- [ ] `P0-14` Add safe environment examples containing names/descriptions only.
- [ ] `P0-15` Record the selected Go version.
- [ ] `P0-16` Record the Flutter stable and Dart versions.
- [ ] `P0-17` Record the Android SDK/minimum SDK targets.
- [ ] `P0-18` Confirm local Postgres or Docker availability for integration tests.
- [ ] `P0-19` Decide and document the common root commands (`Makefile`, scripts, or equivalent).
- [ ] `P0-20` Confirm no credentials or generated secrets are already tracked.

### Exit gate

- [ ] No unresolved product or architecture question blocks the schema or API foundation.
- [ ] All required local tools report usable versions.
- [ ] A new contributor can identify where backend, mobile, prototype, assets, and docs belong.

### Evidence

- Documentation set: `docs/`
- Git remote confirmed: `origin` points to the Sitaara repository.
- Pending: approval sweep, toolchain versions, root project files.

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

**Status:** Not started  
**Depends on:** Phase 0 architecture and toolchain decisions  
**Canonical references:** `06-technical-stack.md`, `07-system-architecture.md`, `12-testing-strategy.md`

### Project scaffold

- [ ] `P1-01` Create `backend/` with a Go module and pinned Go version.
- [ ] `P1-02` Create `cmd/api` and the agreed `internal/` package boundaries.
- [ ] `P1-03` Add a minimal application entry point with clean startup/shutdown.
- [ ] `P1-04` Add focused commands for format, lint, test, integration test, migration, seed, and run.
- [ ] `P1-05` Add `.env.example` with safe placeholders and descriptions.
- [ ] `P1-06` Ensure local secrets and binaries are ignored.

### Configuration and platform behavior

- [ ] `P1-07` Parse configuration once at startup into typed values.
- [ ] `P1-08` Reject missing or unsafe production configuration.
- [ ] `P1-09` Add structured JSON logging with environment, service version, and request ID.
- [ ] `P1-10` Redact secrets and sensitive request data from logs.
- [ ] `P1-11` Add panic recovery and centralized safe error responses.
- [ ] `P1-12` Configure HTTP read, write, idle, and graceful-shutdown timeouts.
- [ ] `P1-13` Add request-body size limits.
- [ ] `P1-14` Implement `/healthz` without dependency checks.
- [ ] `P1-15` Implement `/readyz` with a bounded database ping.

### Postgres and migrations

- [ ] `P1-16` Add `pgx` connection-pool setup using `DATABASE_URL` and TLS configuration.
- [ ] `P1-17` Set conservative configurable connection limits and timeouts.
- [ ] `P1-18` Add `goose` migration tooling and an empty/initial migration path.
- [ ] `P1-19` Add `sqlc` configuration and query-generation command.
- [ ] `P1-20` Verify migrations apply from zero and report their version.
- [ ] `P1-21` Verify application shutdown closes the HTTP server and database pool cleanly.

### Automated verification

- [ ] `P1-22` Add unit-test structure and reusable test helpers.
- [ ] `P1-23` Add an integration-test Postgres environment.
- [ ] `P1-24` Test configuration validation and production fail-closed behavior.
- [ ] `P1-25` Test liveness and readiness success/failure behavior.
- [ ] `P1-26` Add CI steps for formatting, vet/static analysis, migrations, tests, and API build.
- [ ] `P1-27` Confirm CI does not require production credentials.

### Exit gate

- [ ] A clean checkout can start Postgres, apply migrations, and run the API using documented commands.
- [ ] `/healthz` returns 200 while the process is alive.
- [ ] `/readyz` reflects database availability with a bounded timeout.
- [ ] CI builds and tests the empty service successfully.
- [ ] Logs contain request IDs and no secrets.

### Evidence

- Commit/PR: TBD
- Commands run: TBD
- Test/CI result: TBD

## Phase 2 - Schema and authentication

**Status:** Not started  
**Depends on:** Phase 1  
**Canonical references:** `08-data-model.md`, `09-api-contract.md`, `10-authentication-and-security.md`

### Database schema

- [ ] `P2-01` Add required Postgres extensions, including case-insensitive email support.
- [ ] `P2-02` Create `users` with UUIDs, normalized unique email, password hash, and timestamps.
- [ ] `P2-03` Create `refresh_sessions` with digests, rotation-family fields, expiry, use, and revocation timestamps.
- [ ] `P2-04` Add foreign keys, uniqueness constraints, and session lookup indexes.
- [ ] `P2-05` Generate and review typed `sqlc` queries.
- [ ] `P2-06` Prove the schema migrates both an empty database and the previous migration version.

### Password and session primitives

- [ ] `P2-07` Implement Argon2id hashing with explicit parameters and per-password salt.
- [ ] `P2-08` Implement constant-time password verification and transparent parameter inspection.
- [ ] `P2-09` Enforce password length before hashing and apply request-size limits.
- [ ] `P2-10` Implement signed JWT access tokens with issuer, audience, subject, issued-at, and expiry validation.
- [ ] `P2-11` Implement high-entropy opaque refresh tokens.
- [ ] `P2-12` Store only keyed/digested refresh-token material.
- [ ] `P2-13` Implement transactional refresh rotation.
- [ ] `P2-14` Revoke a rotation family when a consumed token is reused.

### HTTP operations

- [ ] `P2-15` Implement `POST /v1/auth/register`.
- [ ] `P2-16` Implement `POST /v1/auth/login` with non-enumerating invalid-credential errors.
- [ ] `P2-17` Implement `POST /v1/auth/refresh`.
- [ ] `P2-18` Implement idempotent `POST /v1/auth/logout`.
- [ ] `P2-19` Implement bearer-token authentication middleware.
- [ ] `P2-20` Implement `GET /v1/me` with onboarding state.
- [ ] `P2-21` Add stricter rate limits for register, login, and refresh operations.
- [ ] `P2-22` Reject unknown JSON fields and malformed/oversized bodies consistently.

### Verification

- [ ] `P2-23` Unit-test password, token, expiry, issuer, and audience behavior.
- [ ] `P2-24` Integration-test registration, duplicate normalized email, login, logout, and `/v1/me`.
- [ ] `P2-25` Test concurrent refresh so only an allowed rotation outcome succeeds.
- [ ] `P2-26` Test consumed-token reuse and rotation-family revocation.
- [ ] `P2-27` Verify errors and logs contain no password, JWT, refresh token, or digest.
- [ ] `P2-28` Run targeted Go race tests.

### Exit gate

- [ ] Auth sessions work through the published HTTP contract.
- [ ] Database contents do not reveal raw passwords or refresh tokens.
- [ ] Concurrent refresh and replay behavior is executable and documented.

### Evidence

- Commit/PR: TBD
- Migration version: TBD
- Tests: TBD

## Phase 3 - Family, child, and partner linking

**Status:** Not started  
**Depends on:** Phase 2  
**Canonical references:** `04-user-stories-and-acceptance.md`, `08-data-model.md`, `11-domain-rules-and-edge-cases.md`

### Schema and domain policies

- [ ] `P3-01` Create families, family members, children, and partner-invite tables.
- [ ] `P3-02` Enforce one family per account.
- [ ] `P3-03` Enforce one child per family.
- [ ] `P3-04` Enforce at most one Mom and one Dad per family.
- [ ] `P3-05` Validate child name and date of birth using the service clock.
- [ ] `P3-06` Implement unambiguous six-character invite generation.
- [ ] `P3-07` Store only HMAC/keyed invite-code digests.
- [ ] `P3-08` Enforce 24-hour expiry, single use, revocation, and active-invite replacement.

### Use cases and endpoints

- [ ] `P3-09` Implement atomic family/member/child creation.
- [ ] `P3-10` Implement `POST /v1/families`.
- [ ] `P3-11` Implement `GET /v1/family` without accepting a client family ID.
- [ ] `P3-12` Implement invite creation and return the raw code once.
- [ ] `P3-13` Implement transactional invite redemption with row locking.
- [ ] `P3-14` Derive the joining role safely and reject an occupied/same role.
- [ ] `P3-15` Prevent self-linking and cross-family reassignment.
- [ ] `P3-16` Map invalid, expired, used, role-taken, and family-full outcomes to the API contract.
- [ ] `P3-17` Return the updated onboarding/family state from `/v1/me`.
- [ ] `P3-18` Apply rate limiting to invite redemption.

### Verification

- [ ] `P3-19` Test successful creator and partner flows.
- [ ] `P3-20` Test invalid/malformed, expired, revoked, and already-used codes.
- [ ] `P3-21` Test self-link, wrong role, existing family, and full-family rejection.
- [ ] `P3-22` Race two accounts against one invite and prove exactly one wins.
- [ ] `P3-23` Race duplicate family creation for one account.
- [ ] `P3-24` Test unrelated-family access and ID substitution attempts.
- [ ] `P3-25` Verify invite codes and child/family identifiers do not leak in logs or unsafe errors.

### Exit gate

- [ ] Exactly one concurrent invite redemption succeeds.
- [ ] Database constraints remain decisive when application checks race.
- [ ] No endpoint lets a caller select or inspect another family.

### Evidence

- Commit/PR: TBD
- Concurrency test: TBD
- Authorization test: TBD

## Phase 4 - Content and shared activity

**Status:** Not started  
**Depends on:** Phase 3 and prepared seed metadata  
**Canonical references:** `08-data-model.md`, `09-api-contract.md`, `11-domain-rules-and-edge-cases.md`, `14-demo-data-and-content.md`

### Content schema and seed

- [ ] `P4-01` Create masterclass and video tables with ordering and publication constraints.
- [ ] `P4-02` Store Cloudinary public IDs and HTTPS delivery URLs for media/thumbnails.
- [ ] `P4-03` Create likes with a composite uniqueness constraint.
- [ ] `P4-04` Create progress with furthest position, recency, completion, and supporting indexes.
- [ ] `P4-05` Implement an idempotent content seed using stable IDs/slugs.
- [ ] `P4-06` Validate two masterclasses with four ordered videos each and positive canonical durations.

### Read models

- [ ] `P4-07` Implement ordered `GET /v1/masterclasses`.
- [ ] `P4-08` Implement `GET /v1/masterclasses/{id}`.
- [ ] `P4-09` Implement `GET /v1/videos/{id}`.
- [ ] `P4-10` Return own likes, progress, completion, and aggregates.
- [ ] `P4-11` Resolve the partner exclusively through authenticated family membership.
- [ ] `P4-12` Return partner status without partner email or internal identifiers.
- [ ] `P4-13` Calculate duration-weighted masterclass progress.
- [ ] `P4-14` Calculate current-watching state using the agreed 10-minute window.
- [ ] `P4-15` Avoid per-video N+1 queries.

### Mutations

- [ ] `P4-16` Implement idempotent like using desired-state `PUT`.
- [ ] `P4-17` Implement idempotent unlike using desired-state `DELETE`.
- [ ] `P4-18` Implement atomic monotonic progress upsert using `greatest`.
- [ ] `P4-19` Clamp progress to canonical duration.
- [ ] `P4-20` Set completion once at the 90% threshold and never clear it.
- [ ] `P4-21` Update valid recency even when furthest progress does not increase.

### Verification

- [ ] `P4-22` Test duplicate/concurrent likes and unlike retries.
- [ ] `P4-23` Test out-of-order and concurrent progress writes.
- [ ] `P4-24` Test exact 90% boundary and excessive-position clamping.
- [ ] `P4-25` Test weighted aggregation with unequal video durations.
- [ ] `P4-26` Test current-watching boundary and completed-video exclusion.
- [ ] `P4-27` Test unlinked, linked, and unrelated-family read models.
- [ ] `P4-28` Measure/query-test the fixed read-query shape.
- [ ] `P4-29` Complete an API-only end-to-end scenario for two accounts.

### Exit gate

- [ ] The API alone supports registration, linking, content, likes, progress, and partner visibility.
- [ ] Concurrency cannot decrease progress or create duplicate likes.
- [ ] Cross-family activity remains inaccessible.

### Evidence

- Commit/PR: TBD
- API scenario: TBD
- Aggregate/concurrency tests: TBD

## Phase 5 - Flutter foundation and onboarding

**Status:** Not started  
**Depends on:** Phase 4 API contract and approved prototype baseline  
**Canonical references:** `05-mobile-screen-specification.md`, `design.md`, `09-api-contract.md`

### Mobile scaffold

- [ ] `P5-01` Create `mobile/` using the pinned Flutter stable toolchain.
- [ ] `P5-02` Set application ID, minimum Android SDK, versioning, and internet permission.
- [ ] `P5-03` Add Riverpod, `go_router`, Dio, model generation, secure storage, and test dependencies.
- [ ] `P5-04` Create the agreed feature-oriented package structure.
- [ ] `P5-05` Add local and production API-base configuration without secrets.
- [ ] `P5-06` Recreate design tokens, typography, spacing, shapes, and semantic colors in Flutter.
- [ ] `P5-07` Import optimized logo/app-icon assets with correct sizing.
- [ ] `P5-08` Build shared buttons, fields, cards, feedback, loaders, and error components.

### Networking and session lifecycle

- [ ] `P5-09` Implement typed API models and the common response/error envelope.
- [ ] `P5-10` Configure Dio timeouts, safe retry behavior, and request cancellation.
- [ ] `P5-11` Store access/refresh tokens in secure storage only.
- [ ] `P5-12` Restore sessions on app launch.
- [ ] `P5-13` Coordinate refresh so concurrent 401 responses cause one refresh operation.
- [ ] `P5-14` Clear session state and route safely after terminal refresh failure.
- [ ] `P5-15` Ensure logs/crash messages do not expose tokens or passwords.

### Screens and flows

- [ ] `P5-16` Implement Welcome.
- [ ] `P5-17` Implement Sign Up with validation and API errors.
- [ ] `P5-18` Implement Login with validation and invalid-session recovery.
- [ ] `P5-19` Implement onboarding path choice.
- [ ] `P5-20` Implement Create Child and role selection.
- [ ] `P5-21` Implement Join Family and invite-error states.
- [ ] `P5-22` Implement invite display, copy, native share, expiry, and regeneration.
- [ ] `P5-23` Implement account summary and logout.
- [ ] `P5-24` Implement router redirects for loading, signed-out, needs-family, and onboarded states.

### Verification

- [ ] `P5-25` Unit-test repositories, session restoration, and coordinated refresh.
- [ ] `P5-26` Widget-test forms, loading, validation, and API-error states.
- [ ] `P5-27` Widget-test routing for every onboarding state.
- [ ] `P5-28` Run formatter, analyzer, and Flutter tests.
- [ ] `P5-29` Complete the two-session create/invite/join flow against the local API.

### Exit gate

- [ ] Two independent installed app sessions can register and become linked.
- [ ] Tokens persist safely and refresh without duplicate rotations.
- [ ] Flutter matches the approved prototype without embedding its HTML.

### Evidence

- Commit/PR: TBD
- Flutter test/analyze result: TBD
- Two-session flow: TBD

## Phase 6 - Library and video experience

**Status:** Not started  
**Depends on:** Phase 5  
**Canonical references:** `05-mobile-screen-specification.md`, `design.md`, `12-testing-strategy.md`

### Content experience

- [ ] `P6-01` Implement the masterclass library with own and partner summaries.
- [ ] `P6-02` Implement masterclass detail with ordered video rows.
- [ ] `P6-03` Display not-started, in-progress, completed, liked, and current-watching states clearly.
- [ ] `P6-04` Handle an unlinked partner state without broken placeholders.
- [ ] `P6-05` Implement pull-to-refresh and refresh-on-entry behavior.
- [ ] `P6-06` Implement loading, empty, offline, server-error, and retry states.

### Reusable video player

- [ ] `P6-07` Build a reusable `video_player`-based component.
- [ ] `P6-08` Handle initialization, buffering, seeking, play/pause, completion, and playback failure.
- [ ] `P6-09` Send integer progress at a bounded interval.
- [ ] `P6-10` Flush progress on pause, route exit, app lifecycle change, and completion where possible.
- [ ] `P6-11` Dispose controllers and cancel work safely.
- [ ] `P6-12` Keep likes and partner activity usable when video initialization fails.
- [ ] `P6-13` Implement like/unlike with optimistic UI and rollback/reconciliation.

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

- Commit/PR: TBD
- Device/emulator: TBD
- Accessibility/responsive review: TBD

## Phase 7 - Media, demo seed, and hosted environment

**Status:** Not started  
**Depends on:** Phase 4 content schema and Phase 6 player  
**Canonical references:** `13-deployment-runbook.md`, `14-demo-data-and-content.md`, ADR-002, ADR-007

### Licensed media preparation

- [ ] `P7-01` Select eight suitable clips under acceptable reuse terms.
- [ ] `P7-02` Complete the licence manifest for every clip before production seed inclusion.
- [ ] `P7-03` Avoid unapproved Sitaara/Instagram content and unnecessary identifiable children.
- [ ] `P7-04` Process each clip to verified MP4/H.264/AAC with practical 720p bitrate and fast-start metadata.
- [ ] `P7-05` Generate consistent representative thumbnails/posters.
- [ ] `P7-06` Verify and record exact integer durations.
- [ ] `P7-07` Retain processed source files and provenance outside Cloudinary for migration/recovery.

### Cloudinary

- [ ] `P7-08` Create/select the project Cloudinary product environment.
- [ ] `P7-09` Configure Cloudinary credentials only in trusted upload tooling.
- [ ] `P7-10` Upload assets under stable project-owned public IDs.
- [ ] `P7-11` Record media public ID, thumbnail public ID, delivery URLs, duration, and licence entry.
- [ ] `P7-12` Verify anonymous HTTPS access to every seeded asset.
- [ ] `P7-13` Verify seeking/range behavior and playback on the target Android player.
- [ ] `P7-14` Confirm no Cloudinary API secret exists in Git, Railway runtime configuration, or the APK.

### Supabase Postgres and Railway

- [ ] `P7-15` Create/select the Supabase project and nearby region.
- [ ] `P7-16` Configure the appropriate TLS pooler connection for Railway.
- [ ] `P7-17` Verify effective connection limits and select a conservative Go pool size.
- [ ] `P7-18` Create the Railway project/service from the repository.
- [ ] `P7-19` Configure required Railway secrets and non-secret settings.
- [ ] `P7-20` Configure health/readiness checks and public HTTPS domain.
- [ ] `P7-21` Apply migrations once through the controlled release procedure.
- [ ] `P7-22` Run the idempotent content and demo-account seed.
- [ ] `P7-23` Confirm startup/runtime logs expose no secrets.

### Release APK and hosted smoke test

- [ ] `P7-24` Configure the production API base URL using the release flavor/definition.
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

- Railway URL/health result: TBD
- Supabase migration version: TBD
- Cloudinary asset verification: TBD
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
