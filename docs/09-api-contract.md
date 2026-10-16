# HTTP API Contract

**Status:** Approved and implementation-aligned
**Last updated:** 2026-10-16  

## Conventions

- Base path: `/v1`
- JSON request and response bodies.
- UTC timestamps in RFC 3339 format.
- UUIDs serialized as lowercase strings.
- Integer seconds for duration and progress.
- Protected requests use `Authorization: Bearer <access-token>`.
- Mutation retries are safe where explicitly marked idempotent.
- Unknown JSON fields are rejected to catch client mistakes.

## Response shape

Success:

```json
{
  "data": {},
  "meta": { "requestId": "01..." }
}
```

Failure:

```json
{
  "error": {
    "code": "INVITE_EXPIRED",
    "message": "The invite code has expired.",
    "fields": {}
  },
  "meta": { "requestId": "01..." }
}
```

Error messages are safe for display. Logs contain the request ID and internal cause, not secrets.

## Public operations

### `GET /healthz`

Process liveness only. Returns `200` without querying Postgres.

### `GET /readyz`

Performs a short bounded database ping. Returns `200` when ready, `503` otherwise. No environment details are exposed.

### `POST /v1/auth/register`

```json
{
  "email": "parent@example.com",
  "password": "user supplied password"
}
```

Returns `201` with account, onboarding state, access token, refresh token, and expirations. Errors: `VALIDATION_ERROR`, `EMAIL_ALREADY_USED`, `RATE_LIMITED`.

### `POST /v1/auth/login`

Returns `200` with the same session shape. Invalid email or password always returns `401 INVALID_CREDENTIALS`.

### `POST /v1/auth/refresh`

```json
{ "refreshToken": "opaque-token" }
```

Consumes the token and returns a rotated pair. Errors: `INVALID_REFRESH_TOKEN`, `SESSION_REUSED`, `RATE_LIMITED`.

## Protected account operations

### `POST /v1/auth/logout`

Revokes the current refresh session using the refresh token in the body. Idempotent; returns `204` even if already revoked.

### `GET /v1/me`

Returns:

```json
{
  "data": {
    "id": "uuid",
    "email": "parent@example.com",
    "onboardingState": "needs_family",
    "family": null
  }
}
```

Onboarded family includes child, own role, partner role if linked, and family status. Partner email is omitted.

## Family operations

### `POST /v1/families`

```json
{
  "role": "mom",
  "child": {
    "name": "Aarav",
    "dateOfBirth": "2024-04-12"
  }
}
```

Returns `201` with family summary. Errors: `ALREADY_IN_FAMILY`, `CHILD_AGE_OUT_OF_RANGE`, `VALIDATION_ERROR`. The operation is protected against duplicate family creation by database uniqueness; a retry after uncertain transport failure should refetch `/v1/me`.

### `GET /v1/family`

Returns own family, child, own role, and optional partner role. Never accepts a family ID.

### `POST /v1/invites`

Revokes the previous active invite and returns a newly generated raw code exactly once.

```json
{
  "data": {
    "code": "7KM9QW",
    "expiresAt": "2026-10-17T12:00:00Z"
  }
}
```

Errors: `FAMILY_REQUIRED`, `FAMILY_ALREADY_FULL`.

### `POST /v1/invites/redeem`

```json
{
  "code": "7KM9QW",
  "role": "dad"
}
```

Returns `200` with family summary. Errors: `INVITE_INVALID`, `INVITE_EXPIRED`, `INVITE_ALREADY_USED`, `SELF_LINK_NOT_ALLOWED`, `ROLE_TAKEN`, `ALREADY_IN_FAMILY`, `FAMILY_ALREADY_FULL`.

Unknown, revoked, and malformed codes may deliberately share `INVITE_INVALID` to reduce information disclosure. A code known to the caller but expired/used can receive the more actionable states when safely distinguishable.

## Content operations

### `GET /v1/masterclasses`

Returns ordered cards:

```json
{
  "data": [
    {
      "id": "uuid",
      "slug": "understanding-child-behaviour",
      "title": "Understanding Child Behaviour",
      "description": "...",
      "thumbnailUrl": "https://...",
      "videoCount": 4,
      "totalDurationSeconds": 1090,
      "me": {
        "percent": 32,
        "completedVideos": 1,
        "likedVideos": 2
      },
      "partner": {
        "role": "dad",
        "percent": 60,
        "completedVideos": 2,
        "isCurrentlyWatching": true
      }
    }
  ]
}
```

`partner` is null before linking.

### `GET /v1/masterclasses/{masterclassId}`

Returns masterclass metadata, own/partner aggregate, and ordered videos. Each video contains canonical duration, media/thumbnail URLs, own like/progress, and optional partner activity.

Hosted media and thumbnail fields contain public Cloudinary HTTPS delivery URLs. Clients treat them as opaque URLs: Flutter does not construct transformation paths, hold Cloudinary credentials, or upload assets.

### `GET /v1/videos/{videoId}`

Returns one video read model suitable for direct player entry. Unknown content returns `404 CONTENT_NOT_FOUND`.

## Activity operations

### `PUT /v1/videos/{videoId}/like`

Idempotently likes a video. Returns `200` with `{ "liked": true }` whether newly inserted or already present.

### `DELETE /v1/videos/{videoId}/like`

Idempotently unlikes a video. Returns `200` with `{ "liked": false }` whether or not a row existed.

### `PUT /v1/videos/{videoId}/progress`

```json
{ "positionSeconds": 53 }
```

Returns:

```json
{
  "data": {
    "furthestSeconds": 53,
    "durationSeconds": 100,
    "percent": 53,
    "completed": false,
    "lastWatchedAt": "2026-10-16T12:00:00Z"
  }
}
```

The request is monotonic/idempotent with respect to furthest progress. A repeated or lower value can update recency. Negative/non-finite/non-integer values are invalid; excessive values are clamped to canonical duration.

## HTTP status mapping

| Status | Meaning |
|---|---|
| `200/201/204` | Successful read/create/no-content action |
| `400` | Malformed JSON or domain validation failure |
| `401` | Missing, expired, or invalid authentication |
| `403` | Authenticated but not authorized; response reveals no protected ownership |
| `404` | Public content/resource not found or safely hidden |
| `409` | Uniqueness/state conflict such as used invite or occupied role |
| `422` | Optional field-specific semantic validation; use consistently if adopted |
| `429` | Rate limit exceeded |
| `500` | Unexpected server failure with request ID |
| `503` | Dependency unavailable/readiness failure |

## Timeouts and limits

- Request body limit is small and explicit because no upload endpoint exists.
- Server read/write/idle timeouts are configured.
- Database calls inherit request cancellation and have bounded timeouts.
- Login, registration, refresh, and invite redemption receive stricter rate limits.
- The app retries safe reads and explicitly idempotent mutations only; it never blindly retries registration or family creation.

## Future machine-readable contract

An OpenAPI file may be added at repository root or under `backend/api/`. This Markdown document remains the human rationale; OpenAPI becomes the machine-readable shape. Contract tests must detect drift.
