# ADR-004: One Child, One Mom, and One Dad per Family

**Status:** Accepted  
**Date:** 2026-10-16  

## Context

The assignment demonstration needs one couple and one child. The agreed product flow has the first parent create the child and the second join by invite. The agreed role rule is exactly one Mom and one Dad.

## Decision

Model a family with one unique child and at most two memberships. Membership role is either `mom` or `dad`, unique within the family. One user may belong to at most one family. Roles and membership cannot be edited or unlinked in this release.

## Consequences

- Database constraints express the demo's integrity requirements simply.
- Invite role conflicts are deterministic.
- The model intentionally does not represent many real family structures and must be generalized before production use.

## Alternatives

- Role stored only on user: rejected because uniqueness belongs to a family relationship.
- Flexible caregiver labels and many members: more inclusive and production-suitable, but outside the agreed assignment scope.
- Separate child ownership followed by merge: rejected because merge behavior creates unnecessary ambiguity.
