package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"regexp"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	postgresgen "github.com/vgpl2000/Sitaara/backend/internal/postgres/gen"
)

var cloudNamePattern = regexp.MustCompile(`^[a-zA-Z0-9_-]+$`)

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
		baseID := "sitaara/masterclasses/" + masterclass.slug
		if err := queries.UpsertMasterclass(ctx, postgresgen.UpsertMasterclassParams{
			ID:                masterclass.id,
			Slug:              masterclass.slug,
			Title:             masterclass.title,
			Description:       masterclass.description,
			ThumbnailPublicID: baseID + "/thumbnail",
			ThumbnailUrl:      imageURL(cloudName, baseID+"/thumbnail"),
			SortOrder:         int32(masterclassIndex),
			Published:         true,
		}); err != nil {
			return fmt.Errorf("seed masterclass %s: %w", masterclass.slug, err)
		}
		for videoIndex, video := range masterclass.videos {
			videoBaseID := fmt.Sprintf("%s/video-%d", baseID, videoIndex+1)
			if err := queries.UpsertVideo(ctx, postgresgen.UpsertVideoParams{
				ID:                video.id,
				MasterclassID:     masterclass.id,
				Title:             video.title,
				Description:       video.description,
				MediaPublicID:     videoBaseID,
				MediaUrl:          videoURL(cloudName, videoBaseID),
				ThumbnailPublicID: videoBaseID + "-poster",
				ThumbnailUrl:      imageURL(cloudName, videoBaseID+"-poster"),
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
	if masterclassCount != 2 || videoCount != 8 {
		return fmt.Errorf("seed validation failed: got %d masterclasses and %d videos", masterclassCount, videoCount)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit content seed: %w", err)
	}
	_, _ = fmt.Fprintln(os.Stdout, "content seed ready: 2 masterclasses, 8 videos")
	return nil
}

func imageURL(cloudName, publicID string) string {
	return fmt.Sprintf("https://res.cloudinary.com/%s/image/upload/%s.jpg", cloudName, publicID)
}

func videoURL(cloudName, publicID string) string {
	return fmt.Sprintf("https://res.cloudinary.com/%s/video/upload/%s.mp4", cloudName, publicID)
}

func contentSeeds() []masterclassSeed {
	return []masterclassSeed{
		{
			id: uuid.MustParse("10000000-0000-4000-8000-000000000001"), slug: "big-feelings",
			title: "Understanding Big Feelings", description: "Practical ways to notice, name, and navigate difficult emotions together.",
			videos: []videoSeed{
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000001"), title: "Naming the feeling", description: "Help children build a simple vocabulary for strong emotions.", durationSeconds: 60},
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000002"), title: "Co-regulation before correction", description: "Create safety and connection before guiding behaviour.", durationSeconds: 75},
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000003"), title: "Building a calm-down routine", description: "Practice a predictable routine for returning to calm.", durationSeconds: 90},
				{id: uuid.MustParse("11000000-0000-4000-8000-000000000004"), title: "Reconnecting after a difficult moment", description: "Use repair and reassurance after emotions settle.", durationSeconds: 60},
			},
		},
		{
			id: uuid.MustParse("20000000-0000-4000-8000-000000000002"), slug: "connection-through-play",
			title: "Play That Builds Connection", description: "Simple play habits that strengthen attention, cooperation, and closeness.",
			videos: []videoSeed{
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000001"), title: "Following your child's lead", description: "Notice their interests and let them guide a few minutes of play.", durationSeconds: 75},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000002"), title: "Turning routines into play", description: "Add imagination and choice to familiar daily moments.", durationSeconds: 60},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000003"), title: "Simple open-ended play", description: "Use flexible materials that invite creativity without pressure.", durationSeconds: 90},
				{id: uuid.MustParse("22000000-0000-4000-8000-000000000004"), title: "Ending play without a battle", description: "Use clear transitions and connection to make stopping easier.", durationSeconds: 45},
			},
		},
	}
}
