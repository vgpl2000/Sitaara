-- +goose Up
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
    id uuid PRIMARY KEY,
    email citext NOT NULL UNIQUE,
    password_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT users_email_trimmed CHECK (email::text = btrim(email::text)),
    CONSTRAINT users_password_hash_not_empty CHECK (length(password_hash) > 0)
);

CREATE TABLE refresh_sessions (
    id uuid PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_digest text NOT NULL UNIQUE,
    family_id uuid NOT NULL,
    parent_session_id uuid REFERENCES refresh_sessions(id) ON DELETE SET NULL,
    expires_at timestamptz NOT NULL,
    used_at timestamptz,
    revoked_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT refresh_sessions_expiry_after_creation CHECK (expires_at > created_at),
    CONSTRAINT refresh_sessions_used_after_creation CHECK (used_at IS NULL OR used_at >= created_at),
    CONSTRAINT refresh_sessions_revoked_after_creation CHECK (revoked_at IS NULL OR revoked_at >= created_at)
);

CREATE INDEX refresh_sessions_user_state_idx
    ON refresh_sessions (user_id, revoked_at, expires_at);

CREATE INDEX refresh_sessions_family_idx
    ON refresh_sessions (family_id);

-- +goose Down
DROP TABLE IF EXISTS refresh_sessions;
DROP TABLE IF EXISTS users;
DROP EXTENSION IF EXISTS citext;
