# Risks and Trade-offs

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Risk register

| Risk | Likelihood | Impact | Mitigation | Residual limitation |
|---|---|---|---|---|
| Railway trial credit/service unavailable | Medium | High | Verify early; retain Render deployment configuration as fallback | Provider dependency remains |
| Supabase connection exhaustion | Medium | High | Use appropriate pooler, small Go pool, bounded timeouts, monitor | Free-tier limits remain |
| Cloudinary media unavailable, limited, or incompatible | Medium | High | Own licensed source files, process predictable MP4s, retain public IDs, test URLs/device playback, keep replacement path documented | CDN/account/provider dependency remains |
| Android codec/network playback variance | Medium | Medium | H.264/AAC 720p, HTTPS, real-device test, retry UI | Cannot test every device |
| Concurrent invite corruption | Low after controls | High | Transaction locks plus unique constraints and race tests | Multi-region latency not explored |
| Cross-family data leak | Low after controls | Critical | Derive partner server-side, deny by default, authorization suite | Application-level security still requires review |
| Custom auth implementation bug | Medium | High | Narrow scope, standard primitives, rotation tests, short JWT lifetime | No MFA/email verification/recovery |
| Documentation drifts from code | Medium | Medium | Canonical ownership, ADRs, contract/test links, final audit | Requires discipline |
| Brand/content rights ambiguity | Medium | Medium | Use public brand reference sparingly and licensed independent media | Formal brand permission is outside scope |
| Prototype diverges from Flutter | Medium | Medium | Use one canonical `design.md`, approve flows first, and translate components deliberately | Some platform-specific differences remain |
| Demo accounts modified by reviewers | Medium | Medium | Seed meaningful defaults, allow fresh signup, document behavior | No automated reset endpoint |

## Major trade-offs

### APK instead of Flutter Web

Benefits: matches the intended mobile product and demonstrates Flutter directly. Costs: reviewer installation friction and Android-only distribution. Mitigation: provide a release APK, checksum, minimum Android version, and precise installation/demo steps.

### HTML prototype before Flutter

Benefits: validates hierarchy, navigation, copy, branding, and dense partner-progress states cheaply before Flutter work. Costs: creates a second UI artifact that can drift or tempt reuse of simulated business logic. Mitigation: keep it isolated in `/prototype`, use it only as an approved design reference, and implement security and domain rules independently in Go.

### Custom Go authentication instead of Supabase Auth

Benefits: demonstrates Go ownership of identity and authorization. Costs: more security-sensitive code and less time for optional UI polish. The implementation therefore deliberately excludes email verification, reset, MFA, and social login.

### Persistent Go service instead of Vercel functions

Benefits: conventional Go process, simpler connection pooling, clearer architecture, and easier local parity. Costs: Railway/Render lifecycle and possible paid hosting.

### Refresh instead of real-time partner updates

Benefits: reliable, testable, and explicitly permitted by the brief. Costs: activity is not instantly visible. Screen-entry and pull-to-refresh behavior make consistency understandable.

### Duration-weighted masterclass progress

Benefits: partially watched videos count accurately and long videos carry appropriate weight. Costs: a displayed percentage does not equal completed-video ratio. The UI shows both percentage and completed count.

### 90% completion threshold

Benefits: avoids credits/end screens preventing completion and matches common media behavior. Costs: a user can be `Completed` at 90-99%. The UI uses the status label rather than implying 100% watched.

### Six-character invite code

Benefits: easy to read and type. Costs: low offline entropy. Mitigations: HMAC storage, expiry, single use, authenticated redemption, throttling, and ambiguous-character exclusion.

### Public Cloudinary media delivery

Benefits: purpose-built image/video delivery, thumbnail generation, and no large-file proxying through Go. Costs: anyone with a public URL can access demo clips, and the project depends on Cloudinary account limits and delivery behavior. Only licensed non-sensitive assets are stored there; original processed files and licence records remain recoverable outside the provider.

### SQL and `sqlc` instead of ORM

Benefits: transactions, locks, aggregates, and constraints are reviewable. Costs: more SQL and migration care. Generated types reduce routine mistakes.

### Assignment-specific Mom/Dad uniqueness

Benefits: exactly follows the agreed demo constraint and makes role uniqueness easy to enforce. Costs: it is not inclusive or production-general. A real product should model caregiver labels and family structures more flexibly.

## Scope pressure response

If time becomes constrained, preserve in this order:

1. Data constraints and authorization.
2. Linking concurrency tests.
3. Idempotent likes and progress correctness.
4. Hosted two-account flow.
5. Clear README and AI disclosure.
6. Robust mobile error states.
7. Fidelity to the approved prototype and visual refinement.
8. Optional recording or enhancements.

Never trade away family isolation or linking integrity for animation, real-time updates, or extra screens.
