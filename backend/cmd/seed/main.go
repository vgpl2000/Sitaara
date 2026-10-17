package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"regexp"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/vgpl2000/Sitaara/backend/internal/auth"
	postgresgen "github.com/vgpl2000/Sitaara/backend/internal/postgres/gen"
)

var cloudNamePattern = regexp.MustCompile(`^[a-zA-Z0-9_-]+$`)

const demoPassword = "SitaaraDemo2026!"

type demoParentSeed struct {
	id    uuid.UUID
	email string
	role  string
}

type masterclassSeed struct {
	id          uuid.UUID
	slug        string
	title       string
	description string
	videos      []videoSeed
}

type videoSeed struct {
	id              uuid.UUID
	title           string
	description     string
	mediaPublicID   string
	durationSeconds int32
}

func main() {
	if err := run(context.Background()); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(ctx context.Context) error {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return errors.New("DATABASE_URL is required")
	}
	cloudName := os.Getenv("CLOUDINARY_CLOUD_NAME")
	if !cloudNamePattern.MatchString(cloudName) {
		return errors.New("CLOUDINARY_CLOUD_NAME is missing or invalid")
	}

	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		return fmt.Errorf("open database: %w", err)
	}
	defer pool.Close()

	tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin content seed: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()
	queries := postgresgen.New(tx)

	for masterclassIndex, masterclass := range contentSeeds() {
		thumbnailPublicID := masterclass.videos[0].mediaPublicID
		if err := queries.UpsertMasterclass(ctx, postgresgen.UpsertMasterclassParams{
			ID:                masterclass.id,
			Slug:              masterclass.slug,
			Title:             masterclass.title,
			Description:       masterclass.description,
			ThumbnailPublicID: thumbnailPublicID,
			ThumbnailUrl:      videoPosterURL(cloudName, thumbnailPublicID),
			SortOrder:         int32(masterclassIndex),
			Published:         true,
		}); err != nil {
			return fmt.Errorf("seed masterclass %s: %w", masterclass.slug, err)
		}
		for videoIndex, video := range masterclass.videos {
			if err := queries.UpsertVideo(ctx, postgresgen.UpsertVideoParams{
				ID:                video.id,
				MasterclassID:     masterclass.id,
				Title:             video.title,
				Description:       video.description,
				MediaPublicID:     video.mediaPublicID,
				MediaUrl:          videoURL(cloudName, video.mediaPublicID),
				ThumbnailPublicID: video.mediaPublicID,
				ThumbnailUrl:      videoPosterURL(cloudName, video.mediaPublicID),
				DurationSeconds:   video.durationSeconds,
				SortOrder:         int32(videoIndex),
			}); err != nil {
				return fmt.Errorf("seed video %s: %w", video.title, err)
			}
		}
	}

	masterclassIDs := []uuid.UUID{contentSeeds()[0].id, contentSeeds()[1].id}
	masterclassCount, err := queries.CountSeedMasterclasses(ctx, masterclassIDs)
	if err != nil {
		return fmt.Errorf("validate masterclass seed: %w", err)
	}
	videoCount, err := queries.CountSeedVideos(ctx, masterclassIDs)
	if err != nil {
		return fmt.Errorf("validate video seed: %w", err)
	}
	if masterclassCount != 2 || videoCount != 9 {
		return fmt.Errorf("seed validation failed: got %d masterclasses and %d videos", masterclassCount, videoCount)
	}
	if err := seedDemoFamily(ctx, tx); err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit content seed: %w", err)
	}
	_, _ = fmt.Fprintln(os.Stdout, "seed ready: 2 masterclasses, 9 videos, 2 linked demo parents, 1 child")
	return nil
}

func seedDemoFamily(ctx context.Context, tx pgx.Tx) error {
	parents := demoParents()
	hasher := auth.NewPasswordHasher(auth.DefaultPasswordParams(), 1)
	for _, parent := range parents {
		passwordHash, err := hasher.Hash(ctx, demoPassword)
		if err != nil {
			return fmt.Errorf("hash demo password: %w", err)
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO users (id, email, password_hash)
			VALUES ($1, $2, $3)
			ON CONFLICT (id) DO UPDATE
			SET email = EXCLUDED.email,
			    password_hash = EXCLUDED.password_hash,
			    updated_at = now()`, parent.id, parent.email, passwordHash); err != nil {
			return fmt.Errorf("seed demo parent %s: %w", parent.role, err)
		}
	}

	familyID := uuid.MustParse("30000000-0000-4000-8000-000000000001")
	childID := uuid.MustParse("33000000-0000-4000-8000-000000000001")
	if _, err := tx.Exec(ctx, `
		INSERT INTO families (id, created_by)
		VALUES ($1, $2)
		ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by`, familyID, parents[0].id); err != nil {
		return fmt.Errorf("seed demo family: %w", err)
	}
	for _, parent := range parents {
		if _, err := tx.Exec(ctx, `
			INSERT INTO family_members (family_id, user_id, role)
			VALUES ($1, $2, $3::parent_role)
			ON CONFLICT (user_id) DO UPDATE
			SET family_id = EXCLUDED.family_id,
			    role = EXCLUDED.role`, familyID, parent.id, parent.role); err != nil {
			return fmt.Errorf("seed demo %s membership: %w", parent.role, err)
		}
	}
	if _, err := tx.Exec(ctx, `
		INSERT INTO children (id, family_id, name, date_of_birth)
		VALUES ($1, $2, 'Tara', DATE '2022-08-14')
		ON CONFLICT (family_id) DO UPDATE
		SET name = EXCLUDED.name,
		    date_of_birth = EXCLUDED.date_of_birth`, childID, familyID); err != nil {
		return fmt.Errorf("seed demo child: %w", err)
	}

	videos := []struct {
		userID    uuid.UUID
		videoID   uuid.UUID
		progress  int
		completed bool
	}{
		{parents[0].id, uuid.MustParse("11000000-0000-4000-8000-000000000001"), 445, true},
		{parents[1].id, uuid.MustParse("22000000-0000-4000-8000-000000000004"), 45, false},
	}
	now := time.Now().UTC()
	for _, activity := range videos {
		if _, err := tx.Exec(ctx, `
			INSERT INTO video_likes (user_id, video_id)
			VALUES ($1, $2)
			ON CONFLICT (user_id, video_id) DO NOTHING`, activity.userID, activity.videoID); err != nil {
			return fmt.Errorf("seed demo like: %w", err)
		}
		var completedAt any
		if activity.completed {
			completedAt = now
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO video_progress (
				user_id, video_id, furthest_seconds, last_watched_at, completed_at, updated_at
			)
			VALUES ($1, $2, $3, $4, $5, $4)
			ON CONFLICT (user_id, video_id) DO UPDATE
			SET furthest_seconds = EXCLUDED.furthest_seconds,
			    last_watched_at = EXCLUDED.last_watched_at,
			    completed_at = EXCLUDED.completed_at,
			    updated_at = EXCLUDED.updated_at`, activity.userID, activity.videoID, activity.progress, now, completedAt); err != nil {
			return fmt.Errorf("seed demo progress: %w", err)
		}
	}

	return nil
}

func demoParents() []demoParentSeed {
	return []demoParentSeed{
		{id: uuid.MustParse("31000000-0000-4000-8000-000000000001"), email: "mom.demo@sitaara.example", role: "mom"},
		{id: uuid.MustParse("32000000-0000-4000-8000-000000000001"), email: "dad.demo@sitaara.example", role: "dad"},
	}
}

func videoPosterURL(cloudName, publicID string) string {
	return fmt.Sprintf("https://res.cloudinary.com/%s/video/upload/so_1,q_auto,f_jpg/%s.jpg", cloudName, publicID)
}

func videoURL(cloudName, publicID string) string {
	return fmt.Sprintf("https://res.cloudinary.com/%s/video/upload/%s.mp4", cloudName, publicID)
}

func contentSeeds() []masterclassSeed {
	return []masterclassSeed{
		{
			id: uuid.MustParse("10000000-0000-4000-8000-000000000001"), slug: "understanding-child-behaviour",
			title: "Understanding Child Behaviour", description: "Expert guidance for understanding behaviour, tantrums, stories, and emotional growth.",
			videos: []videoSeed{
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000001"), title: "Understanding Child Behaviour", description: "Child psychologist Nupur Paiva explains how to read behaviour with greater empathy.", mediaPublicID: "sitaara/masterclasses/understanding-child-behaviour/01-understanding-child-behaviour", durationSeconds: 445},
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000002"), title: "Growth Comes With Tantrums", description: "See tantrums as part of development and respond with calm, practical support.", mediaPublicID: "sitaara/masterclasses/understanding-child-behaviour/02-growth-comes-with-tantrums", durationSeconds: 92},
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000003"), title: "A Story About Tantrums", description: "A parent-friendly story recommended by a child psychologist for difficult moments.", mediaPublicID: "sitaara/masterclasses/understanding-child-behaviour/03-story-about-tantrums", durationSeconds: 374},
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000004"), title: "Children's Books as a Parenting Ally", description: "Discover how shared stories can open conversations and support children.", mediaPublicID: "sitaara/masterclasses/understanding-child-behaviour/04-childrens-books-as-a-parenting-ally", durationSeconds: 179},
			},
		},
		{
			id: uuid.MustParse("20000000-0000-4000-8000-000000000002"), slug: "everyday-parenting-insights",
			title: "Everyday Parenting Insights", description: "Short, thoughtful guidance for common questions and everyday parenting moments.",
			videos: []videoSeed{
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000001"), title: "Why Your Baby Needs You", description: "A concise perspective on what babies need from the adults caring for them.", mediaPublicID: "sitaara/masterclasses/everyday-parenting-insights/01-why-your-baby-needs-you", durationSeconds: 74},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000002"), title: "The Secret Role of Children's Books", description: "Explore how a thoughtfully chosen story can support a child's inner world.", mediaPublicID: "sitaara/masterclasses/everyday-parenting-insights/02-secret-role-of-childrens-books", durationSeconds: 97},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000003"), title: "The Truth About Isolation", description: "A short reflection on connection, isolation, and children's social experiences.", mediaPublicID: "sitaara/masterclasses/everyday-parenting-insights/03-truth-about-isolation", durationSeconds: 141},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000004"), title: "When Your Child Throws Things", description: "Understand what may sit behind throwing and how to respond constructively.", mediaPublicID: "sitaara/masterclasses/everyday-parenting-insights/04-when-your-child-throws-things", durationSeconds: 77},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000005"), title: "Stop Forcing Your Child", description: "Consider a more respectful way to invite participation without unnecessary pressure.", mediaPublicID: "sitaara/masterclasses/everyday-parenting-insights/05-stop-forcing-your-child", durationSeconds: 66},
			},
		},
	}
}
