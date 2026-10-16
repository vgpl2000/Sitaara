-- name: LockUserForOnboarding :one
SELECT id
FROM users
WHERE id = $1
FOR UPDATE;

-- name: GetMembershipByUser :one
SELECT family_id, user_id, role, joined_at
FROM family_members
WHERE user_id = $1;

-- name: CreateFamily :one
INSERT INTO families (id, created_by)
VALUES ($1, $2)
RETURNING id, created_by, created_at;

-- name: CreateFamilyMember :one
INSERT INTO family_members (family_id, user_id, role)
VALUES ($1, $2, $3)
RETURNING family_id, user_id, role, joined_at;

-- name: CreateChild :one
INSERT INTO children (id, family_id, name, date_of_birth)
VALUES ($1, $2, $3, $4)
RETURNING id, family_id, name, date_of_birth, created_at;

-- name: GetFamilySummaryByUser :one
SELECT
    f.id AS family_id,
    fm.role AS own_role,
    c.id AS child_id,
    c.name AS child_name,
    c.date_of_birth,
    partner.role AS partner_role
FROM family_members fm
JOIN families f ON f.id = fm.family_id
JOIN children c ON c.family_id = f.id
LEFT JOIN family_members partner
    ON partner.family_id = f.id
   AND partner.user_id <> fm.user_id
WHERE fm.user_id = $1;

-- name: LockFamily :one
SELECT id
FROM families
WHERE id = $1
FOR UPDATE;

-- name: CountFamilyMembers :one
SELECT count(*)
FROM family_members
WHERE family_id = $1;

-- name: RoleExistsInFamily :one
SELECT EXISTS (
    SELECT 1
    FROM family_members
    WHERE family_id = $1 AND role = $2
);

-- name: RevokeActiveInvitesByUser :exec
UPDATE partner_invites
SET revoked_at = now()
WHERE inviter_user_id = $1
  AND redeemed_at IS NULL
  AND revoked_at IS NULL;

-- name: CreatePartnerInvite :one
INSERT INTO partner_invites (id, family_id, inviter_user_id, code_digest, expires_at)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, family_id, inviter_user_id, code_digest, expires_at, redeemed_by, redeemed_at, revoked_at, created_at;

-- name: GetPartnerInviteForUpdate :one
SELECT id, family_id, inviter_user_id, code_digest, expires_at, redeemed_by, redeemed_at, revoked_at, created_at
FROM partner_invites
WHERE code_digest = $1
FOR UPDATE;

-- name: RedeemPartnerInvite :execrows
UPDATE partner_invites
SET redeemed_by = $2,
    redeemed_at = $3
WHERE id = $1
  AND redeemed_at IS NULL
  AND revoked_at IS NULL;
