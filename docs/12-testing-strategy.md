# Testing Strategy

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Quality objective

Tests prioritize the failure modes the assignment explicitly evaluates: linking integrity, concurrency, authorization, idempotency, monotonic progress, and consistent cross-account reads. UI snapshot volume is secondary to proving behavior.

## Prototype quality review

Before Flutter UI implementation, verify the standalone prototype separately:

- all screens and primary transitions in `05-mobile-screen-specification.md` are reachable;
- create/join, linked/unlinked, progress, like, invite, loading, validation, offline, and server-error states can be demonstrated;
- layouts remain usable at 320px, 390px, and 430px viewport widths;
- keyboard navigation, visible focus, accessible names, contrast, and reduced motion are checked;
- supplied logos preserve aspect ratio and the primary palette matches `design.md`;
- prototype mock behavior is not counted as a backend test.

## Test layers

### Backend unit tests

Run without network or Postgres where possible:

- Email, password, child name, DOB, role, invite-code, and progress validation.
- Completion threshold boundaries.
- Watch-state and masterclass aggregation calculations.
- Domain error mapping.
- JWT claim validation and expiry behavior with an injected clock.
- Invite generation alphabet/format.
- Log redaction helpers.

### Backend database integration tests

Run against real Postgres with all migrations applied:

- Case-insensitive email uniqueness.
- One-family-per-user constraint.
- One-role-per-family and one-child-per-family constraints.
- Invite generation/revocation.
- Concurrent invite redemption.
- Like insert/delete idempotency.
- Atomic progress `greatest` behavior under out-of-order and concurrent writes.
- Partner aggregate queries and cross-family isolation.
- Refresh-token rotation and reuse handling.

Each test owns isolated data and is safe under parallel execution where declared.

### Backend HTTP tests

Use an in-process HTTP server with real use cases/repositories when practical:

- Strict JSON decoding and body-size limits.
- Status/error code contract.
- Missing/invalid/expired token handling.
- User identity cannot be overridden by request JSON.
- Request IDs appear in responses and logs.
- Sensitive fields never appear in serialized errors.

### Flutter unit tests

- API DTO/domain mapping.
- Progress and role presentation.
- Auth repository secure-storage behavior.
- Coordinated single refresh for concurrent 401 responses.
- Error-code-to-message mapping.
- State controllers for optimistic likes and pull-to-refresh.

### Flutter widget tests

- Auth and onboarding routing gates.
- Create/join validation.
- Linked versus unlinked partner cards.
- Video rows for not started/watching/completed/liked partner states.
- Loading, refresh, offline, and error views.
- Text scaling and narrow-width smoke tests.

### End-to-end verification

Automated Flutter integration tests are desirable for the happy path if stable in CI. Regardless, the release requires a manual two-device/session test against the hosted API and release APK.

## Critical test matrix

| Scenario | Expected result | Level |
|---|---|---|
| Register `Parent@x.com`, then `parent@x.com` | Second rejected | DB/API |
| Two concurrent family creations by same user | At most one membership/family is usable | DB/API |
| Creator redeems own code | Rejected; invite unchanged | Integration |
| Two users redeem same code concurrently | Exactly one succeeds | Concurrency integration |
| Joiner chooses occupied role | `ROLE_TAKEN`; no membership; invite remains valid | Integration |
| Already-linked user redeems new code | Rejected without relink | Integration |
| Like twice | One row; both successful | Integration |
| Unlike twice | Zero rows; both successful | Integration |
| Progress 50 then 20 | Stored furthest is 50 | Integration |
| Concurrent progress 20/70/40 | Stored furthest is 70 | Concurrency integration |
| Progress 89% then 90% | Completion changes only at threshold | Unit/integration |
| Completed then lower report | Remains completed; recency updates | Integration |
| User in Family A reads | No Family B activity present | Authorization integration |
| Sole member reads content | Partner object null | Integration/widget |
| Partner acts then other refreshes | New state visible | Hosted manual |
| Concurrent refresh-token use | One rotation wins; replay handled | Security integration |

## Concurrency test method

The invite test creates one valid code and two eligible accounts, synchronizes goroutines at a barrier, and submits redemption simultaneously. Assert:

- one success;
- one conflict;
- invite has one `redeemed_by`;
- target family has exactly two members;
- losing user has no membership;
- no duplicate role exists.

Progress concurrency similarly launches multiple upserts and verifies the maximum final value with the race detector enabled for Go code.

## Security tests

- Fuzz malformed JWTs and invite codes at parser boundaries.
- Verify algorithm confusion is rejected.
- Verify expired tokens and wrong issuer/audience fail.
- Capture structured logs in tests and assert secrets are absent.
- Attempt IDOR-style resource substitution from an unrelated family.
- Verify partner response omits email, password/session, and internal invite fields.
- Verify database errors are converted to safe public errors.

## Media/player tests

- Verify each seeded Cloudinary public ID and HTTPS delivery URL is present and unique where required.
- Initialize a known Cloudinary-hosted MP4 on the target Android player.
- Verify the selected delivery URL supports seeking/range behavior and the expected H.264/AAC playback profile.
- Load every seeded poster/thumbnail URL anonymously.
- Handle buffering and playback error.
- Report progress at interval and lifecycle boundaries.
- Do not send negative/invalid positions.
- Dispose controllers on route exit.
- Keep own/partner activity UI usable if media initialization fails.

## CI quality gates

Backend pipeline:

1. Format check.
2. Static analysis and vet.
3. Start ephemeral Postgres.
4. Apply migrations from zero.
5. Run unit and integration tests.
6. Run race-enabled tests for targeted packages or all packages when runtime permits.
7. Build the API binary.

Mobile pipeline:

1. Fetch pinned dependencies.
2. Format check.
3. `flutter analyze`.
4. Unit and widget tests.
5. Build a debug APK for compile verification; release signing remains controlled.

No deployment occurs if required gates fail.

## Release checklist

- Clean database migration tested.
- Seed is rerunnable without duplicates.
- Hosted `/healthz` and `/readyz` pass.
- Every seeded Cloudinary asset is anonymously readable, and at least one full video playback/seek test passes on the target Android device.
- Seeded Mom and Dad can both log in.
- Fresh two-account linking passes.
- Cross-account activity appears after refresh.
- Airplane/network interruption has understandable recovery.
- APK uses production API URL and contains no private secrets.
- README credentials and demo steps are accurate.
