-- +goose Up
CREATE TYPE parent_role AS ENUM ('mom', 'dad');

CREATE TABLE families (
    id uuid PRIMARY KEY,
    created_by uuid NOT NULL REFERENCES users(id),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE family_members (
    family_id uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role parent_role NOT NULL,
    joined_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (family_id, user_id),
    CONSTRAINT family_members_one_family_per_user UNIQUE (user_id),
    CONSTRAINT family_members_one_role_per_family UNIQUE (family_id, role)
);

CREATE TABLE children (
    id uuid PRIMARY KEY,
    family_id uuid NOT NULL UNIQUE REFERENCES families(id) ON DELETE CASCADE,
    name text NOT NULL,
    date_of_birth date NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT children_name_trimmed CHECK (name = btrim(name)),
    CONSTRAINT children_name_length CHECK (char_length(name) BETWEEN 1 AND 80)
);

CREATE TABLE partner_invites (
    id uuid PRIMARY KEY,
    family_id uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    inviter_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code_digest text NOT NULL UNIQUE,
    expires_at timestamptz NOT NULL,
    redeemed_by uuid REFERENCES users(id),
    redeemed_at timestamptz,
    revoked_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT partner_invites_redemption_pair CHECK (
        (redeemed_by IS NULL AND redeemed_at IS NULL)
        OR (redeemed_by IS NOT NULL AND redeemed_at IS NOT NULL)
    ),
    CONSTRAINT partner_invites_expiry_after_creation CHECK (expires_at > created_at)
);

CREATE UNIQUE INDEX partner_invites_one_active_per_inviter_idx
    ON partner_invites (inviter_user_id)
    WHERE redeemed_at IS NULL AND revoked_at IS NULL;

CREATE INDEX partner_invites_family_created_idx
    ON partner_invites (family_id, created_at DESC);

-- +goose Down
DROP TABLE IF EXISTS partner_invites;
DROP TABLE IF EXISTS children;
DROP TABLE IF EXISTS family_members;
DROP TABLE IF EXISTS families;
DROP TYPE IF EXISTS parent_role;
