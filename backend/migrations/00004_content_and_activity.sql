-- +goose Up
CREATE TABLE masterclasses (
    id uuid PRIMARY KEY,
    slug text NOT NULL UNIQUE,
    title text NOT NULL,
    description text NOT NULL,
    thumbnail_public_id text NOT NULL UNIQUE,
    thumbnail_url text NOT NULL,
    sort_order integer NOT NULL UNIQUE CHECK (sort_order >= 0),
    published boolean NOT NULL DEFAULT false,
    CONSTRAINT masterclasses_thumbnail_https CHECK (thumbnail_url LIKE 'https://%')
);

CREATE TABLE videos (
    id uuid PRIMARY KEY,
    masterclass_id uuid NOT NULL REFERENCES masterclasses(id) ON DELETE RESTRICT,
    title text NOT NULL,
    description text NOT NULL,
    media_public_id text NOT NULL UNIQUE,
    media_url text NOT NULL,
    thumbnail_public_id text NOT NULL UNIQUE,
    thumbnail_url text NOT NULL,
    duration_seconds integer NOT NULL CHECK (duration_seconds > 0),
    sort_order integer NOT NULL CHECK (sort_order >= 0),
    CONSTRAINT videos_order_within_masterclass UNIQUE (masterclass_id, sort_order),
    CONSTRAINT videos_media_https CHECK (media_url LIKE 'https://%'),
    CONSTRAINT videos_thumbnail_https CHECK (thumbnail_url LIKE 'https://%')
);

CREATE TABLE video_likes (
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id uuid NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, video_id)
);

CREATE TABLE video_progress (
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id uuid NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    furthest_seconds integer NOT NULL CHECK (furthest_seconds >= 0),
    last_watched_at timestamptz NOT NULL,
    completed_at timestamptz,
    updated_at timestamptz NOT NULL,
    PRIMARY KEY (user_id, video_id)
);

CREATE INDEX video_progress_user_recent_idx
    ON video_progress (user_id, last_watched_at DESC);

-- +goose Down
DROP TABLE IF EXISTS video_progress;
DROP TABLE IF EXISTS video_likes;
DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS masterclasses;
