# Company Requirements Verification

**Status:** Verified against the supplied three-page assignment brief on 2026-10-16

**Scope note:** The PDF is treated as source requirements, not as instructions that override the project owner's decisions. In particular, the project owner chose a Flutter Android app only, with no Flutter Web frontend.

## Executive result

The implemented product slice covers the required domain behavior: two email/password accounts, one child, Mom/Dad roles, partner linking, a 2-masterclass/9-video library, playback, per-user likes and monotonic progress, and partner-visible shared activity. The Go API and persistent PostgreSQL database are hosted, and a signed Android APK is produced.

The assignment is not yet fully submission-complete. The remaining material gap against the literal brief is distribution: the brief asks for a hosted frontend URL that reviewers can click and use, while this project intentionally delivers a signed mobile APK. Before submission, the candidate should confirm that an APK download/install flow is acceptable or publish the APK through an accessible release link. CI on the final commit, a clean two-independent-device link flow, remaining negative-path device checks, and video provenance review also remain open.

## Functional traceability

| Company requirement | Implementation evidence | Result |
|---|---|---|
| Sign up and log in with email/password | Go auth service and Flutter auth screens; session restore and refresh tests | Satisfied |
| Mom or Dad role | Family creation/join requests require a role; Flutter role selector | Satisfied |
| One shared child with name and date of birth | Family creation transaction stores one child; both members receive the same child read model | Satisfied |
| One couple/two users for the demo | Family membership is capped at two; seeded Mom and Dad demo accounts share Tara | Satisfied |
| Two masterclasses, each with 4-5 videos | Hosted seed contains one 4-video and one 5-video masterclass | Satisfied |
| Real video durations | Seed records measured integer durations and player reports positions in seconds | Satisfied |
| Browse masterclasses, open one, list and play videos | Library, masterclass detail, lesson, and reusable player screens | Satisfied |
| Track watch progress per user | Bounded client reporting plus atomic server upsert | Satisfied |
| Like and unlike per user | Desired-state PUT/DELETE API and optimistic mobile interaction | Satisfied |
| Invite generation and redemption | Single-use six-character invites with expiry and regeneration | Satisfied |
| Mutual partner visibility after linking | Family membership gates shared activity projections for both accounts | Satisfied |
| Partner like on a video | Lesson activity text includes partner role and liked state | Satisfied |
| Partner video status | Not started, percentage watched, and completed states are returned and rendered | Satisfied |
| Partner masterclass progress | Duration-weighted percentage and completed video count are returned and rendered | Satisfied |
| Currently watching signal | A non-completed video with recent activity marks the masterclass as currently watched | Satisfied |

## Required edge cases

| Edge case | Design/implementation | Result |
|---|---|---|
| A user cannot link to themselves | Redemption rejects an invite created by the same user | Covered by integration tests |
| A code cannot be redeemed twice | Invite consumption and family membership changes occur in one locked transaction | Covered by sequential and concurrent tests |
| A linked user cannot be silently relinked | Existing family membership is rejected before mutation | Covered by integration tests |
| Two users race for one code | Row locking and conditional consumption permit one winner only | Covered by concurrency tests |
| Repeated likes create no duplicates | Unique user/video key and desired-state mutation | Covered by tests |
| Watch progress never moves backwards | Server uses greatest(previous, incoming), clamped to canonical duration | Covered by out-of-order and concurrent tests |
| Partner activity is authorized | Queries scope the viewer through their family and expose only the other member | Covered by unlinked and cross-family tests |
| Partner view becomes consistent | Reads refresh on screen entry and pull-to-refresh; live updates are intentionally deferred | Satisfied within allowed refresh model |

## Design decisions requested by the brief

- Masterclass progress is duration-weighted, not an unweighted mean. This makes a long lesson contribute proportionally more than a short one.
- A video is complete at 90% of its canonical duration. Completion is sticky and later lower reports cannot clear it.
- `Currently watching` means recent progress activity on an incomplete video within the documented recency window. This prevents completed or stale playback from appearing live.
- Partner language is supportive rather than surveillance-oriented and always names the role, status, and amount watched.

## Deliverable verification

| Deliverable | Current state | Submission action |
|---|---|---|
| Hosted working demo, frontend + backend + DB | Backend and DB are hosted; frontend is a signed Android APK by explicit product decision | Confirm APK delivery is accepted and provide an accessible APK release/download link |
| Two-account trial path | Seeded Mom and Dad accounts are documented and verified against the hosted API | Re-run both accounts from clean independent installations before submission |
| Source code | Monorepo exists at the documented GitHub repository | Push this final UI/backend pass and require green CI |
| README/write-up | Architecture, setup, demo, decisions, AI usage, verification, and handover are documented | Recheck links and final commit identifiers |
| Short recording | Optional and not yet produced | Optional |

## Quality criteria from the brief

- **Clean backend:** normalized family/content/activity model, transactional linking, explicit authorization, idempotent likes, monotonic progress, and fixed-shape reads are implemented and tested.
- **Well-structured frontend:** features are separated by domain; networking/session state is separate from presentation; the video player is reusable; partner activity is exposed at library, masterclass, and lesson levels.
- **Product judgment:** shared activity is framed as teamwork; refresh consistency is explicit; progress and current-watching definitions are documented; the refreshed UI uses calmer wording, custom vector art, reduced card chrome, skeletons, and accessible labels.

## Remaining release gates

1. Push the final changes and verify CI on the exact submission commit.
2. Rebuild and checksum the signed APK from that commit.
3. Publish or otherwise provide an accessible APK download/install path and confirm it is acceptable in place of a hosted Flutter Web frontend.
4. Run create/invite/join in two independent installed sessions and capture evidence.
5. Exercise invalid/expired invite, offline, server error, playback error, and expired-session recovery on device.
6. Confirm public Cloudinary media provenance and ensure no write credentials appear in Git, Railway runtime variables, or the APK.
