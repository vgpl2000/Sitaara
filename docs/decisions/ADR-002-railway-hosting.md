# ADR-002: Railway for the Go API

**Status:** Accepted  
**Date:** 2026-10-16  

## Context

The APK needs a stable public HTTPS API. Vercel supports Go as serverless functions, while this design benefits from a conventional process and predictable connection pool. Render free services can introduce a visible cold start.

## Decision

Attempt Railway first for a persistent Go service connected to Supabase Postgres. Keep Render-compatible startup/configuration as a fallback.

## Consequences

- Local and hosted runtime models remain similar.
- Go database pooling and health checks are straightforward.
- Trial/credit and provider availability must be verified before submission.
- Deployment remains portable because configuration is environment based.

## Alternatives

- Vercel: rejected for the primary deployment because the Go runtime is function-oriented and adds serverless database constraints.
- Render free: retained as fallback but cold start is undesirable for a live demonstration.
- Fly.io/Cloud Run: capable but add setup or billing complexity not justified here.
