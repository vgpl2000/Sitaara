-- name: CreateUser :one
INSERT INTO users (id, email, password_hash)
VALUES ($1, $2, $3)
RETURNING id, email::text AS email, password_hash, created_at, updated_at;

-- name: GetUserByEmail :one
SELECT id, email::text AS email, password_hash, created_at, updated_at
FROM users
WHERE email = $1;

-- name: GetUserByID :one
SELECT id, email::text AS email, password_hash, created_at, updated_at
FROM users
WHERE id = $1;

-- name: CreateRefreshSession :one
INSERT INTO refresh_sessions (
    id,
    user_id,
    token_digest,
    family_id,
    parent_session_id,
    expires_at
)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, user_id, token_digest, family_id, parent_session_id, expires_at, used_at, revoked_at, created_at;

-- name: GetRefreshSessionForUpdate :one
SELECT id, user_id, token_digest, family_id, parent_session_id, expires_at, used_at, revoked_at, created_at
FROM refresh_sessions
WHERE token_digest = $1
FOR UPDATE;

-- name: MarkRefreshSessionUsed :execrows
UPDATE refresh_sessions
SET used_at = $2
WHERE id = $1
  AND used_at IS NULL
  AND revoked_at IS NULL;

-- name: RevokeRefreshFamily :execrows
UPDATE refresh_sessions
SET revoked_at = COALESCE(revoked_at, $2)
WHERE family_id = $1
  AND revoked_at IS NULL;

-- name: RevokeRefreshFamilyForUser :execrows
UPDATE refresh_sessions
SET revoked_at = COALESCE(revoked_at, $3)
WHERE family_id = $1
  AND user_id = $2
  AND revoked_at IS NULL;

-- name: CountActiveRefreshSessionsInFamily :one
SELECT count(*)
FROM refresh_sessions
WHERE family_id = $1
  AND revoked_at IS NULL;
