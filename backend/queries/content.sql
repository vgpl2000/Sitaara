-- name: UserHasFamily :one
SELECT EXISTS (SELECT 1 FROM family_members WHERE user_id = $1);

-- name: ListMasterclassCards :many
WITH viewer AS (
    SELECT own.family_id,
           partner.user_id AS partner_id,
           partner.role AS partner_role
    FROM family_members own
    LEFT JOIN family_members partner
      ON partner.family_id = own.family_id
     AND partner.user_id <> own.user_id
    WHERE own.user_id = sqlc.arg(user_id)
), video_stats AS (
    SELECT m.id,
           count(v.id)::integer AS video_count,
           COALESCE(sum(v.duration_seconds), 0)::bigint AS total_duration,
           COALESCE(sum(LEAST(COALESCE(me_progress.furthest_seconds, 0), v.duration_seconds)), 0)::bigint AS me_watched,
           count(me_progress.completed_at)::integer AS me_completed,
           count(me_like.video_id)::integer AS me_liked,
           COALESCE(sum(LEAST(COALESCE(partner_progress.furthest_seconds, 0), v.duration_seconds)), 0)::bigint AS partner_watched,
           count(partner_progress.completed_at)::integer AS partner_completed,
           COALESCE(bool_or(
               partner_progress.completed_at IS NULL
               AND partner_progress.furthest_seconds > 0
               AND partner_progress.last_watched_at >= now() - interval '10 minutes'
           ), false) AS partner_watching
    FROM masterclasses m
    JOIN videos v ON v.masterclass_id = m.id
    CROSS JOIN viewer
    LEFT JOIN video_progress me_progress
      ON me_progress.video_id = v.id AND me_progress.user_id = sqlc.arg(user_id)
    LEFT JOIN video_likes me_like
      ON me_like.video_id = v.id AND me_like.user_id = sqlc.arg(user_id)
    LEFT JOIN video_progress partner_progress
      ON partner_progress.video_id = v.id AND partner_progress.user_id = viewer.partner_id
    WHERE m.published
    GROUP BY m.id
)
SELECT m.id,
       m.slug,
       m.title,
       m.description,
       m.thumbnail_url,
       stats.video_count,
       stats.total_duration,
       CASE WHEN stats.total_duration = 0 THEN 0 ELSE floor(100.0 * stats.me_watched / stats.total_duration)::integer END AS me_percent,
       stats.me_completed,
       stats.me_liked,
       viewer.partner_role,
       CASE WHEN viewer.partner_id IS NULL OR stats.total_duration = 0 THEN 0 ELSE floor(100.0 * stats.partner_watched / stats.total_duration)::integer END AS partner_percent,
       stats.partner_completed,
       stats.partner_watching::boolean AS partner_watching
FROM masterclasses m
JOIN video_stats stats ON stats.id = m.id
CROSS JOIN viewer
ORDER BY m.sort_order;

-- name: GetMasterclassMetadata :one
SELECT id, slug, title, description, thumbnail_url
FROM masterclasses
WHERE id = $1 AND published;

-- name: ListMasterclassVideos :many
WITH viewer AS (
    SELECT partner.user_id AS partner_id,
           partner.role AS partner_role
    FROM family_members own
    LEFT JOIN family_members partner
      ON partner.family_id = own.family_id
     AND partner.user_id <> own.user_id
    WHERE own.user_id = sqlc.arg(user_id)
)
SELECT v.id,
       v.title,
       v.description,
       v.media_url,
       v.thumbnail_url,
       v.duration_seconds,
       v.sort_order,
       (me_like.video_id IS NOT NULL)::boolean AS me_liked,
       COALESCE(me_progress.furthest_seconds, 0)::integer AS me_furthest,
       (me_progress.completed_at IS NOT NULL)::boolean AS me_completed,
       viewer.partner_role,
       (partner_like.video_id IS NOT NULL)::boolean AS partner_liked,
       COALESCE(partner_progress.furthest_seconds, 0)::integer AS partner_furthest,
       (partner_progress.completed_at IS NOT NULL)::boolean AS partner_completed,
       COALESCE(
           partner_progress.completed_at IS NULL
           AND partner_progress.furthest_seconds > 0
           AND partner_progress.last_watched_at >= now() - interval '10 minutes',
           false
       )::boolean AS partner_watching
FROM videos v
CROSS JOIN viewer
LEFT JOIN video_likes me_like ON me_like.video_id = v.id AND me_like.user_id = sqlc.arg(user_id)
LEFT JOIN video_progress me_progress ON me_progress.video_id = v.id AND me_progress.user_id = sqlc.arg(user_id)
LEFT JOIN video_likes partner_like ON partner_like.video_id = v.id AND partner_like.user_id = viewer.partner_id
LEFT JOIN video_progress partner_progress ON partner_progress.video_id = v.id AND partner_progress.user_id = viewer.partner_id
WHERE v.masterclass_id = sqlc.arg(masterclass_id)
ORDER BY v.sort_order;

-- name: GetPublishedVideo :one
SELECT v.id, v.masterclass_id, v.title, v.description, v.media_url, v.thumbnail_url, v.duration_seconds, v.sort_order
FROM videos v
JOIN masterclasses m ON m.id = v.masterclass_id
WHERE v.id = $1 AND m.published;

-- name: LikeVideo :exec
INSERT INTO video_likes (user_id, video_id)
SELECT $1, v.id
FROM videos v
JOIN masterclasses m ON m.id = v.masterclass_id
WHERE v.id = $2 AND m.published
ON CONFLICT DO NOTHING;

-- name: UnlikeVideo :exec
DELETE FROM video_likes
WHERE user_id = $1 AND video_id = $2;

-- name: UpsertVideoProgress :one
INSERT INTO video_progress (user_id, video_id, furthest_seconds, last_watched_at, completed_at, updated_at)
SELECT sqlc.arg(user_id),
       v.id,
       LEAST(sqlc.arg(position_seconds)::integer, v.duration_seconds),
       now(),
       CASE WHEN LEAST(sqlc.arg(position_seconds)::integer, v.duration_seconds)::bigint * 10 >= v.duration_seconds::bigint * 9 THEN now() END,
       now()
FROM videos v
JOIN masterclasses m ON m.id = v.masterclass_id
WHERE v.id = sqlc.arg(video_id) AND m.published
ON CONFLICT (user_id, video_id) DO UPDATE
SET furthest_seconds = GREATEST(video_progress.furthest_seconds, EXCLUDED.furthest_seconds),
    last_watched_at = EXCLUDED.last_watched_at,
    completed_at = CASE
        WHEN video_progress.completed_at IS NOT NULL THEN video_progress.completed_at
        WHEN GREATEST(video_progress.furthest_seconds, EXCLUDED.furthest_seconds)::bigint * 10 >=
             (SELECT duration_seconds::bigint FROM videos WHERE id = EXCLUDED.video_id) * 9
        THEN EXCLUDED.last_watched_at
    END,
    updated_at = EXCLUDED.updated_at
RETURNING furthest_seconds,
          (SELECT duration_seconds FROM videos WHERE id = video_progress.video_id) AS duration_seconds,
          completed_at,
          last_watched_at;

-- name: CountVideoLikesByUser :one
SELECT count(*) FROM video_likes WHERE user_id = $1 AND video_id = $2;
