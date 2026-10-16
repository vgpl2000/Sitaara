# Sitaara Partner Linking and Shared Progress - Documentation

**Status:** Draft for review  
**Last updated:** 2026-10-16  
**Owners:** Project author and Codex  

## Purpose

This directory is the single source of truth for the Sitaara full-stack assignment. It defines the product, domain rules, mobile experience, visual system, standalone design prototype, backend contracts, security model, testing approach, deployment procedure, and implementation order before production code is written.

If implementation and documentation disagree, either the implementation must be corrected or the relevant document must be deliberately updated with a decision record. Silent divergence is not acceptable.

## Reading order

1. [Assignment analysis](01-assignment-analysis.md)
2. [Product requirements](02-product-requirements.md)
3. [User flows](03-user-flows.md)
4. [User stories and acceptance criteria](04-user-stories-and-acceptance.md)
5. [Mobile screen specification](05-mobile-screen-specification.md)
6. [Mobile design system and prototype contract](design.md)
7. [Technical stack](06-technical-stack.md)
8. [System architecture](07-system-architecture.md)
9. [Data model](08-data-model.md)
10. [API contract](09-api-contract.md)
11. [Authentication and security](10-authentication-and-security.md)
12. [Domain rules and edge cases](11-domain-rules-and-edge-cases.md)
13. [Testing strategy](12-testing-strategy.md)
14. [Deployment runbook](13-deployment-runbook.md)
15. [Demo data and content](14-demo-data-and-content.md)
16. [Implementation plan](15-implementation-plan.md)
17. [Risks and trade-offs](16-risks-and-tradeoffs.md)
18. [AI usage and verification](17-ai-usage-and-verification.md)
19. [Architecture decision records](decisions/README.md)

## Canonical ownership

| Concern | Canonical document |
|---|---|
| Scope and product behavior | `02-product-requirements.md` |
| Navigation and end-user flow | `03-user-flows.md` |
| Testable acceptance | `04-user-stories-and-acceptance.md` |
| Screens, states, and UI copy | `05-mobile-screen-specification.md` |
| Brand tokens, components, accessibility, and prototype contract | `design.md` |
| Libraries and infrastructure choices | `06-technical-stack.md` |
| Component boundaries | `07-system-architecture.md` |
| Tables, constraints, and indexes | `08-data-model.md` |
| HTTP interface | `09-api-contract.md` |
| Authentication and authorization | `10-authentication-and-security.md` |
| Linking, likes, and progress invariants | `11-domain-rules-and-edge-cases.md` |
| Verification | `12-testing-strategy.md` |
| Hosted environment | `13-deployment-runbook.md` |

## Status meanings

- **Draft:** being discussed; implementation must not assume it is final.
- **Approved:** agreed and ready to implement.
- **Implemented:** reflected in code and verified by tests.
- **Superseded:** retained for history but replaced by a linked document or ADR.

## Requirement conventions

- Functional requirements use stable IDs such as `FR-AUTH-001`.
- Non-functional requirements use IDs such as `NFR-SEC-001`.
- Acceptance criteria link back to requirement IDs.
- Tests should reference the acceptance criteria or domain invariant they prove.
- Major decisions use Architecture Decision Records (ADRs).

## Glossary

| Term | Meaning |
|---|---|
| Account | A registered parent identity with an email and password. |
| Family | The boundary that contains exactly one child and at most two parents. |
| Partner | The other parent in the same family. |
| Invite | A single-use, expiring code that permits one account to join a family. |
| Masterclass | An ordered collection of videos. |
| Furthest progress | The greatest valid playback position ever reported by a user for a video. |
| Completed | Furthest progress is at least 90% of the video's canonical duration. |
| Currently watching | A non-completed video received a progress event in the previous 10 minutes. |
| Prototype | A separate HTML/CSS/JavaScript mobile interaction model used to validate design before Flutter implementation; it is not Flutter Web or the submitted app. |

## Change discipline

1. Update the canonical document first.
2. Add or amend an ADR when the reason for a major decision changes.
3. Update affected acceptance criteria and tests.
4. Use a focused Git commit that explains the decision.
5. Never commit passwords, deployment tokens, database credentials, raw invite codes, or signing keys.
