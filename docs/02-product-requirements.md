# Product Requirements Document

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Product statement

Parenting is collaborative. This feature lets two parents securely join the same family and understand one another's engagement with shared learning content without needing to ask, coordinate manually, or share an account.

## Users

- **Family creator:** registers, chooses a role, creates the child, and generates an invite.
- **Invited parent:** registers, chooses the opposite role, and joins with the invite.
- **Linked parent:** consumes content and sees both personal and partner activity.
- **Reviewer:** uses seeded accounts or creates accounts to verify the end-to-end behavior.

## Product principles

1. Shared activity is visible only after explicit linking.
2. Partner context should be useful but visually secondary to the content.
3. Recovery from ordinary errors should not require database intervention.
4. Important invariants are enforced in both service logic and database constraints.
5. The demo should be understandable without verbal guidance.
6. The approved prototype and Flutter app should share one mobile design system and interaction model.

## Functional requirements

### Authentication

- **FR-AUTH-001:** A visitor can register with a unique email and password.
- **FR-AUTH-002:** A registered user can log in with valid credentials.
- **FR-AUTH-003:** The app can restore a session using a rotating refresh token.
- **FR-AUTH-004:** A user can log out and revoke the current refresh session.
- **FR-AUTH-005:** Authentication failures do not reveal whether a specific email exists.
- **FR-AUTH-006:** An authenticated user can retrieve account, onboarding, family, and partner summary.

### Family and child onboarding

- **FR-FAM-001:** An unassigned account can choose Mom or Dad while creating or joining a family.
- **FR-FAM-002:** A creator can create one family and one child atomically.
- **FR-FAM-003:** Child name is required after trimming and is limited to 80 characters.
- **FR-FAM-004:** Child DOB must be today or earlier and less than six years before the creation date.
- **FR-FAM-005:** A user can belong to no more than one family.
- **FR-FAM-006:** A family can contain at most one Mom and one Dad.
- **FR-FAM-007:** Both linked parents can view the shared child's name and DOB.

### Invites and linking

- **FR-INV-001:** A sole family member can generate an invite valid for 24 hours.
- **FR-INV-002:** Generating a new invite revokes prior unused invites from that user.
- **FR-INV-003:** An unassigned account can redeem a valid invite using the opposite available role.
- **FR-INV-004:** Redemption is single-use and safe under concurrent attempts.
- **FR-INV-005:** A user cannot redeem their own invite.
- **FR-INV-006:** An already-assigned user cannot create or join another family.
- **FR-INV-007:** A full family cannot issue or redeem an invite.
- **FR-INV-008:** Linking is mutual immediately after transaction commit.

### Content

- **FR-CONT-001:** The app lists two ordered seeded masterclasses.
- **FR-CONT-002:** The two masterclasses contain four and five ordered videos respectively, with real durations.
- **FR-CONT-003:** A linked or unlinked family creator can open a masterclass and its videos.
- **FR-CONT-004:** An onboarded user can play a video from a remote HTTPS source.
- **FR-CONT-005:** Content metadata is read-only to mobile users.

### Personal activity

- **FR-ACT-001:** A user can like a video.
- **FR-ACT-002:** Repeating a like request does not create duplicates or fail.
- **FR-ACT-003:** A user can unlike a video; repeating the request remains successful.
- **FR-ACT-004:** The player periodically reports playback position.
- **FR-ACT-005:** Stored furthest progress never decreases.
- **FR-ACT-006:** A video becomes completed at 90% and never returns to incomplete.
- **FR-ACT-007:** Progress is clamped to the canonical video duration.

### Shared activity

- **FR-SHARED-001:** Before linking, no partner activity is returned.
- **FR-SHARED-002:** After linking, a parent can see only the linked partner's activity.
- **FR-SHARED-003:** Video presentation includes partner like and watch status.
- **FR-SHARED-004:** Masterclass presentation includes partner percentage and completed count.
- **FR-SHARED-005:** Current-watching state follows the 10-minute rule.
- **FR-SHARED-006:** Pull-to-refresh retrieves committed partner changes.
- **FR-SHARED-007:** Partner email and security/session data are never included in content responses.

### Demo and operations

- **FR-DEMO-001:** A seeded linked Mom/Dad pair has representative activity.
- **FR-DEMO-002:** Public registration remains available for a fresh linking demonstration.
- **FR-DEMO-003:** A public liveness endpoint reports that the process is running.
- **FR-DEMO-004:** A readiness endpoint verifies required database connectivity.

## Non-functional requirements

- **NFR-SEC-001:** All client traffic uses HTTPS outside local development.
- **NFR-SEC-002:** Passwords, refresh tokens, invite codes, and signing secrets are never logged.
- **NFR-SEC-003:** Every protected query derives the user identity from the verified token, never from a client-supplied user ID.
- **NFR-SEC-004:** Authorization defaults to deny.
- **NFR-REL-001:** Linking, family creation, refresh rotation, and progress writes are transactional or atomic.
- **NFR-REL-002:** Database constraints remain the final defense against duplicate or conflicting records.
- **NFR-PERF-001:** Typical API reads should complete within 500 ms at the service under demo load, excluding host cold start and video transfer.
- **NFR-PERF-002:** List screens avoid per-row database query patterns.
- **NFR-OBS-001:** Requests carry a request ID and emit structured logs without sensitive fields.
- **NFR-MOB-001:** UI supports common Android phone widths and survives rotation without corrupting state.
- **NFR-MOB-002:** Loading, empty, validation, offline/network, unauthorized, and server-error states are explicit.
- **NFR-UX-001:** Primary interaction color is `#462E91`; supplied Sitaara logo artwork retains its `#8AC340` treatment and original proportions.
- **NFR-UX-002:** The mobile interface follows the tokens, components, accessibility rules, and content hierarchy in `design.md`.
- **NFR-UX-003:** A separate `/prototype` implementation uses HTML, CSS, and JavaScript to validate all required journeys before Flutter UI implementation.
- **NFR-UX-004:** The prototype works at 320, 390, and 430 logical-pixel widths and exposes visible keyboard focus.
- **NFR-UX-005:** Prototype simulation is never treated as evidence for backend authorization, concurrency, persistence, or security behavior.
- **NFR-MAINT-001:** Backend domain logic is testable without HTTP concerns.
- **NFR-MAINT-002:** Flutter separates presentation, application state, domain models, and data access.

## Business rules summary

- Account without family: may create or join.
- Family with one member: may generate an invite.
- Family with Mom and Dad: full; no more invites.
- Invite: 24 hours, single-use, revocable, stored only as a keyed digest.
- Video completion: furthest progress at least 90% of duration.
- Masterclass progress: duration-weighted watched percentage.
- Current watching: recent incomplete progress within 10 minutes.

## Release acceptance

Flutter UI implementation begins after the prototype approval gate in `design.md`. The release is accepted only if the automated suite covers authorization, invite concurrency, idempotent likes, monotonic progress, and aggregate progress, and the release APK completes the two-account scenario against the hosted environment.
