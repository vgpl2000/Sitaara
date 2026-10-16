# ADR-006: HTML Prototype Before Flutter

**Status:** Accepted  
**Date:** 2026-10-16

## Context

The assignment requires a Flutter client, but the mobile experience includes authentication, branching onboarding, partner linking, shared progress, video activity, and several error states. Iterating on all of those directly in Flutter would mix design discovery with production architecture and domain implementation.

## Decision

Create a high-fidelity mobile prototype in the root `/prototype` folder using semantic HTML, CSS, and vanilla JavaScript before Flutter UI implementation.

The prototype uses the canonical rules in `design.md`, local copies of the supplied logo assets, and deterministic mock data. It covers the complete screen inventory and primary transitions, including linked/unlinked views and representative loading/error states.

The prototype is not Flutter Web, is not a production client, does not connect to production services, and does not prove authorization, persistence, concurrency, or security behavior. The Flutter app translates the approved experience into native components; the Go service and Postgres remain authoritative for all domain rules.

## Consequences

- Navigation, information hierarchy, copy, and accessibility can be reviewed cheaply before Flutter work.
- Flutter implementation has an explicit visual and interaction reference.
- The repository contains two UI artifacts, so drift is a risk.
- Prototype JavaScript must not become a second source of truth for business rules.
- Approval of the prototype becomes a gate before Flutter UI implementation.

## Alternatives considered

- Design directly in Flutter: rejected because iteration would be slower and would couple UX exploration to production code.
- Flutter Web prototype: rejected because the final client is mobile-only and the user explicitly chose HTML/CSS/JavaScript for design validation.
- Static mockups only: rejected because linking, progress, validation, and back-stack behavior need interactive evaluation.
