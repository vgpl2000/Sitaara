-- name: UpsertMasterclass :exec
INSERT INTO masterclasses (
    id, slug, title, description, thumbnail_public_id, thumbnail_url, sort_order, published
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (id) DO UPDATE
SET slug = EXCLUDED.slug,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    thumbnail_public_id = EXCLUDED.thumbnail_public_id,
    thumbnail_url = EXCLUDED.thumbnail_url,
    sort_order = EXCLUDED.sort_order,
    published = EXCLUDED.published;

-- name: UpsertVideo :exec
INSERT INTO videos (
    id, masterclass_id, title, description, media_public_id, media_url,
    thumbnail_public_id, thumbnail_url, duration_seconds, sort_order
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (id) DO UPDATE
SET masterclass_id = EXCLUDED.masterclass_id,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    media_public_id = EXCLUDED.media_public_id,
    media_url = EXCLUDED.media_url,
    thumbnail_public_id = EXCLUDED.thumbnail_public_id,
    thumbnail_url = EXCLUDED.thumbnail_url,
    duration_seconds = EXCLUDED.duration_seconds,
    sort_order = EXCLUDED.sort_order;

-- name: CountSeedMasterclasses :one
SELECT count(*) FROM masterclasses WHERE id = ANY($1::uuid[]);

-- name: CountSeedVideos :one
SELECT count(*) FROM videos WHERE masterclass_id = ANY($1::uuid[]);
