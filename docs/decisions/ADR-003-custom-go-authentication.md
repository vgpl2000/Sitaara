# ADR-003: Custom Go Authentication

**Status:** Accepted  
**Date:** 2026-10-16  

## Context

Authentication could be delegated to Supabase, but the project author wants it implemented in Go. The assignment values backend correctness, yet the project timeline does not justify a complete consumer identity platform.

## Decision

Implement email/password registration and login in Go using Argon2id, short-lived signed access JWTs, and opaque single-use rotating refresh tokens stored as keyed digests. Exclude email verification, password reset, social login, and MFA.

## Consequences

- Identity and authorization flow are fully explainable within the Go service.
- Security-sensitive behavior requires careful tests and review.
- Demo users must not contain real data.
- The result is assignment-grade, not a complete production identity service.

## Alternatives

- Supabase Auth: fastest and production-capable, but rejected by explicit project choice.
- Long-lived JWT only: rejected because logout/revocation and exposure risk are poor.
- Stateful access sessions only: valid, but JWT access plus database refresh sessions fits the desired API architecture.
