# Authentication and Security

**Status:** Implemented and handover-aligned
**Last updated:** 2026-10-16  

## Security goals

1. A stolen database alone does not reveal passwords, raw refresh tokens, or raw invite codes.
2. A modified APK cannot impersonate another account or select another family.
3. Only two linked members of the same family can see one another's activity.
4. Replayed and concurrent security-sensitive requests fail safely.
5. Logs and error responses do not leak secrets or private cross-family data.

## Passwords

- Hash with Argon2id and a cryptographically random per-password salt.
- Encode algorithm, version, parameters, salt, and digest in the stored hash string.
- Parameters are centralized, benchmarked on the deployed service, and documented in code.
- Password verification uses constant-time comparison through the chosen implementation.
- Set a practical minimum length and generous maximum byte length; allow password managers and spaces.
- Never trim or transform the password itself.
- Login response is identical for unknown email and wrong password.
- Optional dummy-hash verification reduces account-enumeration timing differences.

Email is trimmed and normalized for lookup. Display may use the normalized value because email is not otherwise public to a partner.

## Access tokens

- Signed JWT using a high-entropy deployment secret.
- Short lifetime, proposed 15 minutes.
- Claims: issuer, audience, subject user UUID, session/rotation-family identifier, issued-at, expiry, and unique token ID.
- Middleware accepts only the configured algorithm and validates every required claim.
- No roles or family IDs are trusted from token claims; current authorization state comes from Postgres.
- Clock skew tolerance is narrow and explicit.

## Refresh tokens

- Opaque random value with at least 256 bits of entropy.
- Proposed lifetime: 30 days.
- Only a keyed digest is stored.
- Every successful refresh atomically marks the old session used and creates a successor.
- If an already-used token is presented, treat it as possible theft and revoke the rotation chain.
- Logout revokes the submitted session/chain and succeeds idempotently.
- Flutter stores refresh and access tokens in secure storage, not preferences or logs.

## Mobile refresh coordination

Dio authentication handling must serialize refresh attempts. When multiple requests see an expired token:

1. The first starts refresh.
2. Others await the same future rather than using the refresh token again.
3. On success, waiting requests retry once.
4. On failure, tokens are removed and navigation returns to Login.

This is required because refresh tokens are single-use.

## Authorization rules

- Identity is always the verified JWT subject.
- `/v1/family` derives the family through `family_members.user_id = subject`.
- Partner identity is the other member of that derived family.
- Content IDs may be client supplied because content is shared, but activity joins remain restricted to self/resolved partner.
- Mutations always write `user_id = subject`; request bodies never contain a user ID.
- Invite generation derives the inviter's family rather than accepting a family ID.
- Invite redemption may reveal only safe state errors, never child or inviter details before success.

## Invite security

- Six uppercase characters from an alphabet excluding visually ambiguous characters.
- Normalize whitespace and separators before validation.
- Store `HMAC-SHA-256(invite_secret, normalized_code)`, not a raw or plain hash.
- Compare digests safely.
- Expire in 24 hours and revoke predecessors on regeneration.
- Rate-limit attempts by authenticated account and source address.
- Use database locks and constraints to defeat concurrent redemption.
- Do not include invite codes in request logs, analytics, crash reports, or URL query strings.

## Transport and storage

- Production/demo uses HTTPS only.
- Postgres connections require TLS.
- The APK contains the public API base URL but no database or service secrets.
- Public media contains no user data.
- Railway and Supabase secrets live in their environment/secret stores.
- Cloudinary API credentials exist only in trusted upload/seed tooling; they are never embedded in Flutter or exposed by the Go API.
- Public Cloudinary delivery URLs are acceptable only for licensed, non-sensitive demo assets. Private family or user media is out of scope.
- `.env.example` contains names and safe descriptions only.
- Release signing material remains outside Git.

## Logging and error handling

Allowlist structured log fields rather than logging entire requests. Safe fields include request ID, route template, method, status, latency, authenticated user ID, and typed internal error category.

Never log:

- Authorization headers or JWTs.
- Passwords or password hashes.
- Refresh tokens or digests.
- Invite codes or digests.
- Database URLs.
- Full request bodies for authentication/linking endpoints.

Production responses never contain stack traces, SQL, provider credentials, or raw database errors.

## Abuse controls

- Body size limits and strict JSON decoding.
- Per-IP/account throttles on register, login, refresh, and redeem.
- Database and HTTP timeouts.
- Maximum connection pool size appropriate to Supabase and Railway.
- Bounded password hashing concurrency if needed to protect CPU/memory.
- Generic authentication errors.

Rate limiting is defense in depth for the demo. Core correctness must not depend on in-memory rate-limit state because the process can restart.

## Threat checklist

| Threat | Control |
|---|---|
| Credential database leak | Argon2id salts and calibrated cost |
| Refresh database leak | Only keyed token digests stored |
| Invite table leak/brute force | HMAC digest, expiry, attempt throttling |
| IDOR/cross-family reads | Derive partner from authenticated membership |
| Duplicate/competing redemption | Locks, unique constraints, transaction |
| Replay of refresh token | Single-use rotation and reuse-chain revocation |
| Progress rollback | Atomic `greatest` upsert |
| Secret leakage in logs | Allowlisted structured fields and redaction tests |
| Compromised APK | Server-side authentication and authorization |

## Accepted limitations

- No email ownership verification.
- No password reset, MFA, device management, or account recovery.
- No certificate pinning.
- Access JWT revocation is bounded by its short lifetime.
- Public demo accounts are intentionally non-private and must contain no personal data.

These limitations are disclosed in the final README and are appropriate only for the assignment demo.
