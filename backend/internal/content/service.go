package content

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	postgresgen "github.com/vgpl2000/Sitaara/backend/internal/postgres/gen"
)

var (
	ErrContentNotFound  = errors.New("content not found")
	ErrOnboardingNeeded = errors.New("family onboarding required")
)

type ValidationError struct {
	Fields map[string]string
}

func (e *ValidationError) Error() string { return "content validation failed" }

type ProgressSummary struct {
	Percent         int32 `json:"percent"`
	CompletedVideos int32 `json:"completedVideos"`
}

type MeSummary struct {
	ProgressSummary
	LikedVideos int32 `json:"likedVideos"`
}

type PartnerSummary struct {
	Role string `json:"role"`
	ProgressSummary
	IsCurrentlyWatching bool `json:"isCurrentlyWatching"`
}

type MasterclassCard struct {
	ID                   uuid.UUID       `json:"id"`
	Slug                 string          `json:"slug"`
	Title                string          `json:"title"`
	Description          string          `json:"description"`
	ThumbnailURL         string          `json:"thumbnailUrl"`
	VideoCount           int32           `json:"videoCount"`
	TotalDurationSeconds int64           `json:"totalDurationSeconds"`
	Me                   MeSummary       `json:"me"`
	Partner              *PartnerSummary `json:"partner"`
}

type Activity struct {
	Liked           bool  `json:"liked"`
	FurthestSeconds int32 `json:"furthestSeconds"`
	Percent         int32 `json:"percent"`
	Completed       bool  `json:"completed"`
}

type PartnerActivity struct {
	Role                string `json:"role"`
	Liked               bool   `json:"liked"`
	FurthestSeconds     int32  `json:"furthestSeconds"`
	Percent             int32  `json:"percent"`
	Completed           bool   `json:"completed"`
	IsCurrentlyWatching bool   `json:"isCurrentlyWatching"`
}

type Video struct {
	ID              uuid.UUID        `json:"id"`
	MasterclassID   uuid.UUID        `json:"masterclassId,omitempty"`
	Title           string           `json:"title"`
	Description     string           `json:"description"`
	MediaURL        string           `json:"mediaUrl"`
	ThumbnailURL    string           `json:"thumbnailUrl"`
	DurationSeconds int32            `json:"durationSeconds"`
	SortOrder       int32            `json:"sortOrder"`
	Me              Activity         `json:"me"`
	Partner         *PartnerActivity `json:"partner"`
}

type MasterclassDetail struct {
	ID           uuid.UUID       `json:"id"`
	Slug         string          `json:"slug"`
	Title        string          `json:"title"`
	Description  string          `json:"description"`
	ThumbnailURL string          `json:"thumbnailUrl"`
	Me           ProgressSummary `json:"me"`
	Partner      *PartnerSummary `json:"partner"`
	Videos       []Video         `json:"videos"`
}

type ProgressResult struct {
	FurthestSeconds int32     `json:"furthestSeconds"`
	DurationSeconds int32     `json:"durationSeconds"`
	Percent         int32     `json:"percent"`
	Completed       bool      `json:"completed"`
	LastWatchedAt   time.Time `json:"lastWatchedAt"`
}

type Service struct {
	queries *postgresgen.Queries
}

func NewService(pool *pgxpool.Pool) *Service {
	return &Service{queries: postgresgen.New(pool)}
}

func (s *Service) ListMasterclasses(ctx context.Context, userID uuid.UUID) ([]MasterclassCard, error) {
	if err := s.ensureOnboarded(ctx, userID); err != nil {
		return nil, err
	}
	rows, err := s.queries.ListMasterclassCards(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list masterclasses: %w", err)
	}
	cards := make([]MasterclassCard, 0, len(rows))
	for _, row := range rows {
		card := MasterclassCard{
			ID:                   row.ID,
			Slug:                 row.Slug,
			Title:                row.Title,
			Description:          row.Description,
			ThumbnailURL:         row.ThumbnailUrl,
			VideoCount:           row.VideoCount,
			TotalDurationSeconds: row.TotalDuration,
			Me: MeSummary{
				ProgressSummary: ProgressSummary{Percent: row.MePercent, CompletedVideos: row.MeCompleted},
				LikedVideos:     row.MeLiked,
			},
		}
		if row.PartnerRole.Valid {
			card.Partner = &PartnerSummary{
				Role:                string(row.PartnerRole.ParentRole),
				ProgressSummary:     ProgressSummary{Percent: row.PartnerPercent, CompletedVideos: row.PartnerCompleted},
				IsCurrentlyWatching: row.PartnerWatching,
			}
		}
		cards = append(cards, card)
	}
	return cards, nil
}

func (s *Service) GetMasterclass(ctx context.Context, userID, masterclassID uuid.UUID) (MasterclassDetail, error) {
	if err := s.ensureOnboarded(ctx, userID); err != nil {
		return MasterclassDetail{}, err
	}
	metadata, err := s.queries.GetMasterclassMetadata(ctx, masterclassID)
	if errors.Is(err, pgx.ErrNoRows) {
		return MasterclassDetail{}, ErrContentNotFound
	}
	if err != nil {
		return MasterclassDetail{}, fmt.Errorf("get masterclass: %w", err)
	}
	videos, err := s.listVideos(ctx, userID, masterclassID)
	if err != nil {
		return MasterclassDetail{}, err
	}
	me, partner := aggregate(videos)
	return MasterclassDetail{
		ID:           metadata.ID,
		Slug:         metadata.Slug,
		Title:        metadata.Title,
		Description:  metadata.Description,
		ThumbnailURL: metadata.ThumbnailUrl,
		Me:           me,
		Partner:      partner,
		Videos:       videos,
	}, nil
}

func (s *Service) GetVideo(ctx context.Context, userID, videoID uuid.UUID) (Video, error) {
	if err := s.ensureOnboarded(ctx, userID); err != nil {
		return Video{}, err
	}
	metadata, err := s.queries.GetPublishedVideo(ctx, videoID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Video{}, ErrContentNotFound
	}
	if err != nil {
		return Video{}, fmt.Errorf("get video: %w", err)
	}
	videos, err := s.listVideos(ctx, userID, metadata.MasterclassID)
	if err != nil {
		return Video{}, err
	}
	for _, video := range videos {
		if video.ID == videoID {
			video.MasterclassID = metadata.MasterclassID
			return video, nil
		}
	}
	return Video{}, ErrContentNotFound
}

func (s *Service) SetLiked(ctx context.Context, userID, videoID uuid.UUID, liked bool) (bool, error) {
	if err := s.ensureOnboarded(ctx, userID); err != nil {
		return false, err
	}
	if _, err := s.queries.GetPublishedVideo(ctx, videoID); errors.Is(err, pgx.ErrNoRows) {
		return false, ErrContentNotFound
	} else if err != nil {
		return false, fmt.Errorf("validate liked video: %w", err)
	}
	if liked {
		if err := s.queries.LikeVideo(ctx, postgresgen.LikeVideoParams{UserID: userID, ID: videoID}); err != nil {
			return false, fmt.Errorf("like video: %w", err)
		}
	} else if err := s.queries.UnlikeVideo(ctx, postgresgen.UnlikeVideoParams{UserID: userID, VideoID: videoID}); err != nil {
		return false, fmt.Errorf("unlike video: %w", err)
	}
	return liked, nil
}

func (s *Service) UpdateProgress(ctx context.Context, userID, videoID uuid.UUID, position int32) (ProgressResult, error) {
	if position < 0 {
		return ProgressResult{}, &ValidationError{Fields: map[string]string{"positionSeconds": "Position must be zero or greater."}}
	}
	if err := s.ensureOnboarded(ctx, userID); err != nil {
		return ProgressResult{}, err
	}
	row, err := s.queries.UpsertVideoProgress(ctx, postgresgen.UpsertVideoProgressParams{
		UserID: userID, PositionSeconds: position, VideoID: videoID,
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return ProgressResult{}, ErrContentNotFound
	}
	if err != nil {
		return ProgressResult{}, fmt.Errorf("update video progress: %w", err)
	}
	return ProgressResult{
		FurthestSeconds: row.FurthestSeconds,
		DurationSeconds: row.DurationSeconds,
		Percent:         percentage(row.FurthestSeconds, row.DurationSeconds),
		Completed:       row.CompletedAt.Valid,
		LastWatchedAt:   row.LastWatchedAt.Time,
	}, nil
}

func (s *Service) ensureOnboarded(ctx context.Context, userID uuid.UUID) error {
	onboarded, err := s.queries.UserHasFamily(ctx, userID)
	if err != nil {
		return fmt.Errorf("check content access: %w", err)
	}
	if !onboarded {
		return ErrOnboardingNeeded
	}
	return nil
}

func (s *Service) listVideos(ctx context.Context, userID, masterclassID uuid.UUID) ([]Video, error) {
	rows, err := s.queries.ListMasterclassVideos(ctx, postgresgen.ListMasterclassVideosParams{
		UserID: userID, MasterclassID: masterclassID,
	})
	if err != nil {
		return nil, fmt.Errorf("list masterclass videos: %w", err)
	}
	videos := make([]Video, 0, len(rows))
	for _, row := range rows {
		video := Video{
			ID:              row.ID,
			MasterclassID:   masterclassID,
			Title:           row.Title,
			Description:     row.Description,
			MediaURL:        row.MediaUrl,
			ThumbnailURL:    row.ThumbnailUrl,
			DurationSeconds: row.DurationSeconds,
			SortOrder:       row.SortOrder,
			Me: Activity{
				Liked: row.MeLiked, FurthestSeconds: row.MeFurthest,
				Percent: percentage(row.MeFurthest, row.DurationSeconds), Completed: row.MeCompleted,
			},
		}
		if row.PartnerRole.Valid {
			video.Partner = &PartnerActivity{
				Role: string(row.PartnerRole.ParentRole), Liked: row.PartnerLiked,
				FurthestSeconds:     row.PartnerFurthest,
				Percent:             percentage(row.PartnerFurthest, row.DurationSeconds),
				Completed:           row.PartnerCompleted,
				IsCurrentlyWatching: row.PartnerWatching,
			}
		}
		videos = append(videos, video)
	}
	return videos, nil
}

func aggregate(videos []Video) (ProgressSummary, *PartnerSummary) {
	var totalDuration, meWatched, partnerWatched int64
	var meCompleted, partnerCompleted int32
	var partner *PartnerSummary
	for _, video := range videos {
		totalDuration += int64(video.DurationSeconds)
		meWatched += int64(min(video.Me.FurthestSeconds, video.DurationSeconds))
		if video.Me.Completed {
			meCompleted++
		}
		if video.Partner != nil {
			if partner == nil {
				partner = &PartnerSummary{Role: video.Partner.Role}
			}
			partnerWatched += int64(min(video.Partner.FurthestSeconds, video.DurationSeconds))
			if video.Partner.Completed {
				partnerCompleted++
			}
			partner.IsCurrentlyWatching = partner.IsCurrentlyWatching || video.Partner.IsCurrentlyWatching
		}
	}
	me := ProgressSummary{Percent: weightedPercentage(meWatched, totalDuration), CompletedVideos: meCompleted}
	if partner != nil {
		partner.ProgressSummary = ProgressSummary{Percent: weightedPercentage(partnerWatched, totalDuration), CompletedVideos: partnerCompleted}
	}
	return me, partner
}

func percentage(value, total int32) int32 {
	if total <= 0 {
		return 0
	}
	return int32(min(int64(100), int64(value)*100/int64(total)))
}

func weightedPercentage(value, total int64) int32 {
	if total <= 0 {
		return 0
	}
	return int32(min(int64(100), value*100/total))
}
