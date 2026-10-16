# ADR-001: Go API with Supabase Postgres and Storage

**Status:** Accepted  
**Date:** 2026-10-16  

## Context

The assignment requires Go, Flutter, a real hosted database, and a backend whose integrity and authorization can be evaluated. Supabase can provide many application features directly, but using its client data APIs for business operations would move important logic outside Go.

## Decision

Flutter calls only the Go API for application JSON operations. Go owns authentication, authorization, partner linking, likes, progress, and partner read models. Supabase supplies hosted Postgres and a public bucket for licensed non-sensitive sample media.

## Consequences

- Backend behavior remains explicit and testable.
- Database credentials never reach Flutter.
- More Go code and deployment configuration are required.
- Supabase Auth, PostgREST, Realtime, and Edge Functions are unnecessary.

## Alternatives

- Supabase Auth plus Go authorization: rejected because custom Go auth was explicitly selected.
- Flutter direct to Supabase: rejected because it weakens the backend demonstration and splits authorization.
- Self-hosted Postgres: rejected as unnecessary operational work for the assignment.
