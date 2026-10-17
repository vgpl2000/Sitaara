//go:build integration

package content

import (
	"context"
	"errors"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var firstSeedVideoID = uuid.MustParse("11000000-0000-4000-8000-000000000001")

func TestContentActivityAndPartnerIsolation(t *testing.T) {
	service, pool := integrationContentService(t)
	mom, dad, outsider := createContentUsers(t, pool)
	t.Cleanup(func() { deleteContentUsers(t, pool, mom, dad, outsider) })
	createLinkedFamily(t, pool, mom, dad)
	createSoloFamily(t, pool, outsider)

	cards, err := service.ListMasterclasses(context.Background(), mom)
	if err != nil {
		t.Fatalf("ListMasterclasses returned error: %v", err)
	}
	if len(cards) != 2 || cards[0].VideoCount != 4 {
		t.Fatalf("masterclass cards = %#v", cards)
	}
	if cards[0].Me.Percent != 0 || cards[0].Me.CompletedVideos != 0 ||
		cards[0].Partner == nil || cards[0].Partner.Percent != 0 {
		t.Fatalf("unwatched masterclass activity = %#v", cards[0])
	}

	if liked, err := service.SetLiked(context.Background(), mom, firstSeedVideoID, true); err != nil || !liked {
		t.Fatalf("first like = %v, %v", liked, err)
	}
	if liked, err := service.SetLiked(context.Background(), mom, firstSeedVideoID, true); err != nil || !liked {
		t.Fatalf("idempotent like = %v, %v", liked, err)
	}
	var likeWorkers sync.WaitGroup
	likeErrors := make(chan error, 2)
	for range 2 {
		likeWorkers.Add(1)
		go func() {
			defer likeWorkers.Done()
			_, likeErr := service.SetLiked(context.Background(), mom, firstSeedVideoID, true)
			likeErrors <- likeErr
		}()
	}
	likeWorkers.Wait()
	close(likeErrors)
	for likeErr := range likeErrors {
		if likeErr != nil {
			t.Fatalf("concurrent like error: %v", likeErr)
		}
	}
	var likeCount int
	if err := pool.QueryRow(context.Background(), "select count(*) from video_likes where user_id = $1 and video_id = $2", mom, firstSeedVideoID).Scan(&likeCount); err != nil || likeCount != 1 {
		t.Fatalf("like count = %d, error = %v", likeCount, err)
	}
	for range 2 {
		if liked, err := service.SetLiked(context.Background(), mom, firstSeedVideoID, false); err != nil || liked {
			t.Fatalf("idempotent unlike = %v, %v", liked, err)
		}
	}
	if err := pool.QueryRow(context.Background(), "select count(*) from video_likes where user_id = $1 and video_id = $2", mom, firstSeedVideoID).Scan(&likeCount); err != nil || likeCount != 0 {
		t.Fatalf("like count after unlike = %d, error = %v", likeCount, err)
	}
	if _, err := service.SetLiked(context.Background(), mom, firstSeedVideoID, true); err != nil {
		t.Fatalf("restore like: %v", err)
	}
	if liked, err := service.SetLiked(context.Background(), outsider, firstSeedVideoID, true); err != nil || !liked {
		t.Fatalf("outsider like = %v, %v", liked, err)
	}

	var duration int32
	if err := pool.QueryRow(context.Background(), "select duration_seconds from videos where id = $1", firstSeedVideoID).Scan(&duration); err != nil {
		t.Fatalf("read seeded video duration: %v", err)
	}
	completionThreshold := (duration*9 + 9) / 10
	beforeThreshold := completionThreshold - 1

	progress, err := service.UpdateProgress(context.Background(), mom, firstSeedVideoID, beforeThreshold)
	if err != nil || progress.Completed || progress.FurthestSeconds != beforeThreshold {
		t.Fatalf("progress before threshold = %#v, %v", progress, err)
	}
	progress, err = service.UpdateProgress(context.Background(), mom, firstSeedVideoID, completionThreshold)
	if err != nil || !progress.Completed || progress.Percent != 90 {
		t.Fatalf("progress at threshold = %#v, %v", progress, err)
	}
	progress, err = service.UpdateProgress(context.Background(), mom, firstSeedVideoID, 20)
	if err != nil || !progress.Completed || progress.FurthestSeconds != completionThreshold {
		t.Fatalf("lower progress changed completion = %#v, %v", progress, err)
	}
	progress, err = service.UpdateProgress(context.Background(), mom, firstSeedVideoID, duration+999)
	if err != nil || progress.FurthestSeconds != duration || progress.Percent != 100 || !progress.Completed {
		t.Fatalf("clamped progress = %#v, %v", progress, err)
	}

	dadVideo, err := service.GetVideo(context.Background(), dad, firstSeedVideoID)
	if err != nil {
		t.Fatalf("dad GetVideo: %v", err)
	}
	if dadVideo.Partner == nil || dadVideo.Partner.Role != "mom" || !dadVideo.Partner.Liked || dadVideo.Partner.FurthestSeconds != duration || dadVideo.Partner.IsCurrentlyWatching {
		t.Fatalf("dad partner activity = %#v", dadVideo.Partner)
	}
	outsiderVideo, err := service.GetVideo(context.Background(), outsider, firstSeedVideoID)
	if err != nil {
		t.Fatalf("outsider GetVideo: %v", err)
	}
	if outsiderVideo.Partner != nil {
		t.Fatalf("outsider received unrelated partner activity: %#v", outsiderVideo.Partner)
	}
}

func TestConcurrentProgressKeepsMaximum(t *testing.T) {
	service, pool := integrationContentService(t)
	user := createContentUser(t, pool, "progress-race")
	t.Cleanup(func() { deleteContentUsers(t, pool, user) })
	createSoloFamily(t, pool, user)

	start := make(chan struct{})
	errorsChannel := make(chan error, 3)
	var workers sync.WaitGroup
	for _, position := range []int32{20, 50, 40} {
		workers.Add(1)
		go func(value int32) {
			defer workers.Done()
			<-start
			_, err := service.UpdateProgress(context.Background(), user, firstSeedVideoID, value)
			errorsChannel <- err
		}(position)
	}
	close(start)
	workers.Wait()
	close(errorsChannel)
	for err := range errorsChannel {
		if err != nil {
			t.Fatalf("concurrent progress error: %v", err)
		}
	}

	video, err := service.GetVideo(context.Background(), user, firstSeedVideoID)
	if err != nil {
		t.Fatalf("GetVideo returned error: %v", err)
	}
	if video.Me.FurthestSeconds != 50 {
		t.Fatalf("furthest seconds = %d, want 50", video.Me.FurthestSeconds)
	}
}

func TestContentRequiresFamilyAndPublishedResource(t *testing.T) {
	service, pool := integrationContentService(t)
	user := createContentUser(t, pool, "unonboarded")
	t.Cleanup(func() { deleteContentUsers(t, pool, user) })
	if _, err := service.ListMasterclasses(context.Background(), user); !errors.Is(err, ErrOnboardingNeeded) {
		t.Fatalf("unonboarded list error = %v", err)
	}
	createSoloFamily(t, pool, user)
	if _, err := service.GetVideo(context.Background(), user, uuid.New()); !errors.Is(err, ErrContentNotFound) {
		t.Fatalf("unknown video error = %v", err)
	}
}

func TestContentReadsUseFixedQueryCounts(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("TEST_DATABASE_URL is not set")
	}
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		t.Fatalf("parse test database config: %v", err)
	}
	counter := &queryCounter{}
	config.ConnConfig.Tracer = counter
	pool, err := pgxpool.NewWithConfig(context.Background(), config)
	if err != nil {
		t.Fatalf("open traced test database: %v", err)
	}
	t.Cleanup(pool.Close)
	service := NewService(pool)
	user := createContentUser(t, pool, "query-count")
	t.Cleanup(func() { deleteContentUsers(t, pool, user) })
	createSoloFamily(t, pool, user)

	counter.count.Store(0)
	cards, err := service.ListMasterclasses(context.Background(), user)
	if err != nil {
		t.Fatalf("ListMasterclasses returned error: %v", err)
	}
	if got := counter.count.Load(); got != 2 {
		t.Fatalf("ListMasterclasses query count = %d, want 2", got)
	}

	counter.count.Store(0)
	if _, err := service.GetMasterclass(context.Background(), user, cards[0].ID); err != nil {
		t.Fatalf("GetMasterclass returned error: %v", err)
	}
	if got := counter.count.Load(); got != 3 {
		t.Fatalf("GetMasterclass query count = %d, want 3", got)
	}
}

func integrationContentService(t *testing.T) (*Service, *pgxpool.Pool) {
	t.Helper()
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("TEST_DATABASE_URL is not set")
	}
	pool, err := pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		t.Fatalf("open test database: %v", err)
	}
	t.Cleanup(pool.Close)
	return NewService(pool), pool
}

func createContentUsers(t *testing.T, pool *pgxpool.Pool) (uuid.UUID, uuid.UUID, uuid.UUID) {
	t.Helper()
	return createContentUser(t, pool, "mom"), createContentUser(t, pool, "dad"), createContentUser(t, pool, "outsider")
}

func createContentUser(t *testing.T, pool *pgxpool.Pool, prefix string) uuid.UUID {
	t.Helper()
	id := uuid.New()
	email := fmt.Sprintf("%s-%s@example.test", prefix, uuid.NewString())
	if _, err := pool.Exec(context.Background(), "insert into users (id, email, password_hash) values ($1, $2, 'test-hash')", id, email); err != nil {
		t.Fatalf("create content user: %v", err)
	}
	return id
}

func createLinkedFamily(t *testing.T, pool *pgxpool.Pool, mom, dad uuid.UUID) {
	t.Helper()
	createFamilyFixture(t, pool, mom, &dad)
}

func createSoloFamily(t *testing.T, pool *pgxpool.Pool, user uuid.UUID) {
	t.Helper()
	createFamilyFixture(t, pool, user, nil)
}

func createFamilyFixture(t *testing.T, pool *pgxpool.Pool, creator uuid.UUID, partner *uuid.UUID) {
	t.Helper()
	familyID := uuid.New()
	if _, err := pool.Exec(context.Background(), "insert into families (id, created_by) values ($1, $2)", familyID, creator); err != nil {
		t.Fatalf("create family fixture: %v", err)
	}
	if _, err := pool.Exec(context.Background(), "insert into family_members (family_id, user_id, role) values ($1, $2, 'mom')", familyID, creator); err != nil {
		t.Fatalf("create creator membership: %v", err)
	}
	if partner != nil {
		if _, err := pool.Exec(context.Background(), "insert into family_members (family_id, user_id, role) values ($1, $2, 'dad')", familyID, *partner); err != nil {
			t.Fatalf("create partner membership: %v", err)
		}
	}
	if _, err := pool.Exec(context.Background(), "insert into children (id, family_id, name, date_of_birth) values ($1, $2, 'Aarav', $3)", uuid.New(), familyID, time.Now().AddDate(-2, 0, 0)); err != nil {
		t.Fatalf("create child fixture: %v", err)
	}
}

func deleteContentUsers(t *testing.T, pool *pgxpool.Pool, userIDs ...uuid.UUID) {
	t.Helper()
	if _, err := pool.Exec(context.Background(), "delete from families where created_by = any($1)", userIDs); err != nil {
		t.Errorf("delete content families: %v", err)
	}
	if _, err := pool.Exec(context.Background(), "delete from users where id = any($1)", userIDs); err != nil {
		t.Errorf("delete content users: %v", err)
	}
}

type queryCounter struct {
	count atomic.Int64
}

func (q *queryCounter) TraceQueryStart(ctx context.Context, _ *pgx.Conn, _ pgx.TraceQueryStartData) context.Context {
	q.count.Add(1)
	return ctx
}

func (q *queryCounter) TraceQueryEnd(context.Context, *pgx.Conn, pgx.TraceQueryEndData) {}
