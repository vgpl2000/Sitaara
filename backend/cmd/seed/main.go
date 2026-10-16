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
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit content seed: %w", err)
	}
	_, _ = fmt.Fprintln(os.Stdout, "content seed ready: 2 masterclasses, 9 videos")
	return nil
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
