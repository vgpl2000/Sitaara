# AI Usage and Verification Log

**Status:** Active; update throughout the project  
**Last updated:** 2026-10-16  

## Purpose

The assignment explicitly welcomes AI and asks how it was used. This document records assistance honestly, identifies the human-owned decisions, and explains how generated work was verified before acceptance.

## Working policy

- AI may help analyze requirements, propose designs, draft code/tests/docs, explain Go, and inspect failures.
- The project author owns every accepted product and technical decision.
- Security, data integrity, authorization, transactions, and deployment behavior require direct review and executable verification.
- Generated code is not trusted because it compiles; tests and reasoning must demonstrate its behavior.
- Significant mistakes caught during review are recorded because they show the verification process.

## Decision ownership

Human decisions already confirmed:

- Deliver Android APK rather than Flutter Web.
- Validate the full mobile experience first in a separate HTML/CSS/JavaScript `/prototype` folder.
- Use primary purple `#462E91`, preserve the supplied green `#8AC340` logo treatment, and use local supplied assets.
- Use Go-owned authentication.
- Use Railway for the first hosting attempt.
- Use Supabase for Postgres and media storage, not authentication.
- Creator makes the child; partner joins that child.
- Enforce one Mom and one Dad.
- Use 24-hour single-use invites.
- Use 90% completion, weighted aggregate progress, and 10-minute current-watching window.
- Use pull-to-refresh.
- Prioritize correctness, tests, and documentation.
- Use independent royalty-free content and Sitaara-inspired branding.

## Activity log

| Date | Area | AI assistance | Human input/decision | Verification |
|---|---|---|---|---|
| 2026-10-16 | Assignment analysis | Extracted and organized requirements from the supplied brief | Confirmed mobile APK, hosting, auth, roles, progress, and scope | Compared against all three pages of the source brief |
| 2026-10-16 | Hosting research | Compared Vercel, Railway, Render, and Supabase connection models | Selected Railway first, Render fallback | Checked current official provider documentation |
| 2026-10-16 | Documentation | Drafted product, UX, architecture, schema, API, security, test, and delivery documents | Will review/approve before implementation | Cross-document consistency scan and later implementation traceability |
| 2026-10-16 | Brand and prototype planning | Reconciled the website-derived design notes with confirmed mobile branding and proposed a prototype contract | Confirmed Flutter mobile only, separate HTML/CSS/JavaScript prototype, supplied logos, `#462E91` purple, and `#8AC340` green | Inspected all local assets and audited every Markdown document for conflicting platform or brand guidance |

## Verification methods

### Requirements and design

- Trace every source requirement into stable functional requirements.
- Link user stories and tests to those IDs.
- Review diagrams against prose and schema.
- Challenge each security boundary with an unauthorized-user scenario.
- Record alternatives and consequences in ADRs.

### Backend-generated code

- Read every migration and query directly.
- Run migrations against an empty real Postgres instance.
- Run integration and concurrency tests.
- Use Go race detection where relevant.
- Inspect error paths and transaction rollback behavior.
- Confirm logs do not contain secrets.

### Flutter-generated code

- Run formatter, analyzer, unit tests, and widget tests.
- Exercise on an Android emulator and at least one clean install if available.
- Inspect token storage and refresh coordination.
- Verify controller disposal and progress flush lifecycle.
- Test loading, offline, invalid-session, and server-error states.

### Deployment-generated configuration

- Review every environment variable and ensure no secret enters Git/APK.
- Apply migrations and smoke test the hosted environment.
- Install the release APK, not only debug builds.
- Repeat the exact README reviewer flow.

### Prototype-generated code

- Review every screen against `05-mobile-screen-specification.md` and `design.md`.
- Test the mobile frame at 320px, 390px, and 430px widths.
- Verify keyboard navigation, visible focus, accessible names, contrast, and reduced motion.
- Treat local mock flows as design evidence only, never as proof of backend correctness.

## Mistake log template

Record non-trivial issues rather than presenting AI use as flawless.

```text
Date:
Area:
Generated suggestion or implementation:
Why it was wrong or incomplete:
How it was detected:
Correction:
Test or control added:
```

## Final write-up questions

Before submission, answer:

1. Which files or components were mostly AI-drafted?
2. Which core decisions were made by the author and why?
3. Which suggestions were rejected?
4. What defects were caught through review/tests?
5. What Go concepts can the author explain without relying on the tool?
6. How were concurrency, authorization, and token behavior independently verified?
7. Where would the design change for a production Sitaara system?

## Explanation readiness

The author should be able to explain:

- Why database uniqueness is needed in addition to Go checks.
- How one invite redemption wins under concurrency.
- Why desired-state like endpoints are idempotent.
- Why progress uses an atomic maximum.
- How partner authorization is derived without trusting a partner ID.
- Why refresh tokens are opaque, hashed, and rotated.
- Why duration-weighted progress was chosen.
- Why real-time updates and wider family models were deferred.
