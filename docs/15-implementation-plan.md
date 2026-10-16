# Implementation Plan

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Delivery strategy

Approve the mobile experience through a standalone high-fidelity prototype, then build vertically around the risky backend invariants. Each phase ends with runnable code, tests, and documentation updates. Git commits should be small enough to explain and review.

Day-to-day task status, phase gates, and verification evidence are tracked in `18-implementation-checklist.md`. This document defines the implementation order; the checklist records execution progress.

## Phase 0 - Approve contracts

- Review and approve this documentation.
- Confirm the mobile design system, supplied logos, and purple/green brand roles.
- Confirm repository checkout and Git remote.
- Add root README skeleton, ignore rules, and environment examples.
- Record dependency/toolchain versions at scaffold time.

Definition of done: no unresolved product question blocks schema or API work.

## Phase 0A - Mobile experience prototype

- Create the separate root `/prototype` folder using semantic HTML, CSS, and vanilla JavaScript.
- Implement all screens and transitions in `05-mobile-screen-specification.md` with deterministic mock state.
- Demonstrate both account perspectives, linking, content progress, likes, and representative failure states.
- Apply `design.md`, use optimized copies of the supplied assets, and validate 320/390/430px widths.
- Run the prototype approval gate and revise navigation, hierarchy, copy, and accessibility findings.
- Freeze an approved prototype reference before Flutter UI implementation begins.

Definition of done: the prototype passes every approval criterion in `design.md`; no production backend or Flutter code is implied by this phase.

## Phase 1 - Backend foundation

- Scaffold Go service and package boundaries.
- Parse/validate configuration.
- Add structured logging, request IDs, recovery, timeouts, health/readiness.
- Add Postgres connection and migration tooling.
- Configure CI with ephemeral Postgres.

Definition of done: empty service builds, tests, migrates, and reports readiness.

## Phase 2 - Schema and authentication

- Implement initial schema and generated queries.
- Registration and login with Argon2id.
- JWT issue/validation.
- Opaque refresh sessions, rotation, reuse handling, logout.
- Auth middleware and `/v1/me`.
- Add security and HTTP contract tests.

Definition of done: sessions work through HTTP and concurrent refresh behavior is tested.

## Phase 3 - Family, child, and partner linking

- Atomic family/child creation.
- Invite generation with HMAC digest and expiry.
- Transactional invite redemption.
- Role/family constraints and public error mapping.
- Full invalid/concurrent linking test matrix.

Definition of done: exactly one concurrent redemption wins and cross-family access tests pass.

## Phase 4 - Content and activity

- Add masterclass/video seed schema and read models.
- Add idempotent like/unlike.
- Add monotonic progress and completion logic.
- Add personal/partner video and masterclass aggregates.
- Test query count/shape and isolation.

Definition of done: API alone supports the complete assignment scenario.

## Phase 5 - Flutter foundation and onboarding

- Scaffold app, theme, environment flavor, routing, networking, secure storage.
- Translate the approved prototype into native Flutter components rather than embedding or shipping the HTML prototype.
- Implement session restoration and coordinated refresh.
- Build Welcome, Sign Up, Login, path choice, Create Child, and Join Family.
- Build invite display/copy/share and account/logout.
- Add state and widget tests.

Definition of done: two installed app sessions can create and link accounts.

## Phase 6 - Library and video experience

- Library cards and partner summaries.
- Masterclass detail and video rows.
- Reusable video player with progress lifecycle reporting.
- Like/unlike and optimistic recovery.
- Pull-to-refresh and all common error states.
- Accessibility/responsive pass.

Definition of done: full mobile story works against local backend.

## Phase 7 - Media, demo seed, and hosting

- Acquire, document, process, and upload licensed media.
- Finalize seed metadata and demo accounts.
- Create the Supabase Postgres project, Cloudinary media environment, and Railway service.
- Upload media through trusted tooling, record public IDs/delivery URLs, and verify Android playback.
- Apply migrations and seed.
- Configure production APK URL and build release artifact.

Definition of done: hosted API and database work from a cleanly installed APK.

## Phase 8 - Verification and submission

- Run automated pipelines and race/concurrency tests.
- Execute release manual checklist with two sessions.
- Review logs for secret leakage and errors.
- Finish root README, architecture explanation, AI report, and trade-offs.
- Verify repo history is understandable.
- Produce APK checksum and final links.
- Optional screen recording only after core deliverables are complete.

Definition of done: a reviewer can follow the README without assistance.

## Proposed Git history

Examples of focused commits:

1. `docs: define product and technical contracts`
2. `feat(prototype): validate mobile journeys and design system`
3. `chore: scaffold Go API and CI`
4. `feat(api): add schema and account authentication`
5. `feat(api): implement transactional partner linking`
6. `feat(api): add content, likes, and progress read models`
7. `test(api): cover concurrency and family authorization`
8. `chore: scaffold Flutter app architecture`
9. `feat(app): add authentication and family onboarding`
10. `feat(app): add library and partner activity`
11. `feat(app): add reusable player and progress reporting`
12. `ops: add hosted configuration and demo seed`
13. `docs: complete demo guide and AI verification report`

Do not manufacture artificial history after implementation; commit coherent working increments as they are built.

## Definition of done for every feature

- Requirements and acceptance criteria identified.
- Domain and authorization behavior implemented server-side.
- Error states mapped in API and mobile.
- Automated tests cover happy path and important failure path.
- Formatting/static analysis pass.
- No secrets or unrelated generated files committed.
- Documentation updated if behavior changed.
