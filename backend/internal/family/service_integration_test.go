//go:build integration

package family

import (
	"context"
	"errors"
	"fmt"
	"os"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestFamilyCreateInviteAndRedeem(t *testing.T) {
	service, pool := integrationFamilyService(t, time.Now)
	creator := createTestUser(t, pool, "creator")
	joiner := createTestUser(t, pool, "joiner")
	t.Cleanup(func() { deleteTestFamiliesAndUsers(t, pool, creator, joiner) })

	created, err := service.Create(context.Background(), creator, "mom", " Aarav ", time.Now().AddDate(-2, 0, 0).Format("2006-01-02"))
	if err != nil {
		t.Fatalf("Create returned error: %v", err)
	}
	if created.OwnRole != "mom" || created.Status != "waiting_for_partner" || created.Child.Name != "Aarav" {
		t.Fatalf("created family = %#v", created)
	}
	if _, err := service.Create(context.Background(), creator, "dad", "Other", "2024-01-01"); !errors.Is(err, ErrAlreadyInFamily) {
		t.Fatalf("duplicate family error = %v", err)
	}

	invite, err := service.CreateInvite(context.Background(), creator)
	if err != nil {
		t.Fatalf("CreateInvite returned error: %v", err)
	}
	if _, err := service.RedeemInvite(context.Background(), creator, invite.Code, "dad"); !errors.Is(err, ErrSelfLinkNotAllowed) {
		t.Fatalf("self-link error = %v", err)
	}
	if _, err := service.RedeemInvite(context.Background(), joiner, invite.Code, "mom"); !errors.Is(err, ErrRoleTaken) {
		t.Fatalf("occupied role error = %v", err)
	}

	joined, err := service.RedeemInvite(context.Background(), joiner, invite.Code, "dad")
	if err != nil {
		t.Fatalf("RedeemInvite returned error: %v", err)
	}
	if joined.Status != "linked" || joined.PartnerRole == nil || *joined.PartnerRole != "mom" {
		t.Fatalf("joined family = %#v", joined)
	}
	creatorView, err := service.Get(context.Background(), creator)
	if err != nil {
		t.Fatalf("Get creator family: %v", err)
	}
	if creatorView.PartnerRole == nil || *creatorView.PartnerRole != "dad" {
		t.Fatalf("creator view = %#v", creatorView)
	}
	if _, err := service.RedeemInvite(context.Background(), joiner, invite.Code, "dad"); !errors.Is(err, ErrInviteAlreadyUsed) {
		t.Fatalf("reused invite error = %v", err)
	}
	if _, err := service.CreateInvite(context.Background(), creator); !errors.Is(err, ErrFamilyAlreadyFull) {
		t.Fatalf("full-family invite error = %v", err)
	}
}

func TestConcurrentInviteRedemptionAllowsExactlyOneJoiner(t *testing.T) {
	service, pool := integrationFamilyService(t, time.Now)
	creator := createTestUser(t, pool, "race-creator")
	firstJoiner := createTestUser(t, pool, "race-first")
	secondJoiner := createTestUser(t, pool, "race-second")
	t.Cleanup(func() { deleteTestFamiliesAndUsers(t, pool, creator, firstJoiner, secondJoiner) })

	if _, err := service.Create(context.Background(), creator, "mom", "Aarav", time.Now().AddDate(-2, 0, 0).Format("2006-01-02")); err != nil {
		t.Fatalf("Create returned error: %v", err)
	}
	invite, err := service.CreateInvite(context.Background(), creator)
	if err != nil {
		t.Fatalf("CreateInvite returned error: %v", err)
	}

	type result struct {
		userID uuid.UUID
		err    error
	}
	start := make(chan struct{})
	results := make(chan result, 2)
	var workers sync.WaitGroup
	for _, userID := range []uuid.UUID{firstJoiner, secondJoiner} {
		workers.Add(1)
		go func(id uuid.UUID) {
			defer workers.Done()
			<-start
			_, redeemErr := service.RedeemInvite(context.Background(), id, invite.Code, "dad")
			results <- result{userID: id, err: redeemErr}
		}(userID)
	}
	close(start)
	workers.Wait()
	close(results)

	successes := 0
	conflicts := 0
	var loser uuid.UUID
	for outcome := range results {
		if outcome.err == nil {
			successes++
		} else if errors.Is(outcome.err, ErrInviteAlreadyUsed) {
			conflicts++
			loser = outcome.userID
		} else {
			t.Fatalf("unexpected redemption error: %v", outcome.err)
		}
	}
	if successes != 1 || conflicts != 1 {
		t.Fatalf("successes = %d, conflicts = %d", successes, conflicts)
	}

	var members int
	if err := pool.QueryRow(context.Background(), "select count(*) from family_members where family_id = $1", inviteFamilyID(t, pool, invite.Code, service.inviteSecret)).Scan(&members); err != nil {
		t.Fatalf("count family members: %v", err)
	}
	if members != 2 {
		t.Fatalf("family members = %d, want 2", members)
	}
	var loserMemberships int
	if err := pool.QueryRow(context.Background(), "select count(*) from family_members where user_id = $1", loser).Scan(&loserMemberships); err != nil {
		t.Fatalf("count loser memberships: %v", err)
	}
	if loserMemberships != 0 {
		t.Fatalf("loser memberships = %d, want 0", loserMemberships)
	}
}

func TestConcurrentFamilyCreationAllowsExactlyOneFamily(t *testing.T) {
	service, pool := integrationFamilyService(t, time.Now)
	user := createTestUser(t, pool, "family-race")
	t.Cleanup(func() { deleteTestFamiliesAndUsers(t, pool, user) })

	start := make(chan struct{})
	errorsChannel := make(chan error, 2)
	var workers sync.WaitGroup
	for range 2 {
		workers.Add(1)
		go func() {
			defer workers.Done()
			<-start
			_, err := service.Create(context.Background(), user, "mom", "Aarav", time.Now().AddDate(-2, 0, 0).Format("2006-01-02"))
			errorsChannel <- err
		}()
	}
	close(start)
	workers.Wait()
	close(errorsChannel)

	successes := 0
	conflicts := 0
	for err := range errorsChannel {
		if err == nil {
			successes++
		} else if errors.Is(err, ErrAlreadyInFamily) {
			conflicts++
		} else {
			t.Fatalf("unexpected family creation error: %v", err)
		}
	}
	if successes != 1 || conflicts != 1 {
		t.Fatalf("successes = %d, conflicts = %d", successes, conflicts)
	}
	var familyCount, childCount int
	if err := pool.QueryRow(context.Background(), "select count(*) from families where created_by = $1", user).Scan(&familyCount); err != nil {
		t.Fatalf("count created families: %v", err)
	}
	if err := pool.QueryRow(context.Background(), "select count(*) from children c join families f on f.id = c.family_id where f.created_by = $1", user).Scan(&childCount); err != nil {
		t.Fatalf("count created children: %v", err)
	}
	if familyCount != 1 || childCount != 1 {
		t.Fatalf("families = %d, children = %d", familyCount, childCount)
	}
}

func TestInviteRegenerationAndExpiry(t *testing.T) {
	now := time.Date(2026, time.October, 16, 12, 0, 0, 0, time.UTC)
	service, pool := integrationFamilyService(t, func() time.Time { return now })
	creator := createTestUser(t, pool, "expiry-creator")
	joiner := createTestUser(t, pool, "expiry-joiner")
	t.Cleanup(func() { deleteTestFamiliesAndUsers(t, pool, creator, joiner) })

	if _, err := service.Create(context.Background(), creator, "mom", "Aarav", "2024-04-12"); err != nil {
		t.Fatalf("Create returned error: %v", err)
	}
	first, err := service.CreateInvite(context.Background(), creator)
	if err != nil {
		t.Fatalf("first CreateInvite: %v", err)
	}
	second, err := service.CreateInvite(context.Background(), creator)
	if err != nil {
		t.Fatalf("second CreateInvite: %v", err)
	}
	if _, err := service.RedeemInvite(context.Background(), joiner, first.Code, "dad"); !errors.Is(err, ErrInviteInvalid) {
		t.Fatalf("revoked predecessor error = %v", err)
	}
	now = now.Add(25 * time.Hour)
	if _, err := service.RedeemInvite(context.Background(), joiner, second.Code, "dad"); !errors.Is(err, ErrInviteExpired) {
		t.Fatalf("expired invite error = %v", err)
	}
}

func integrationFamilyService(t *testing.T, now Clock) (*Service, *pgxpool.Pool) {
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
	return NewService(pool, []byte(strings.Repeat("i", 32)), now), pool
}

func createTestUser(t *testing.T, pool *pgxpool.Pool, prefix string) uuid.UUID {
	t.Helper()
	userID := uuid.New()
	email := fmt.Sprintf("%s-%s@example.test", prefix, uuid.NewString())
	if _, err := pool.Exec(context.Background(), "insert into users (id, email, password_hash) values ($1, $2, 'test-hash')", userID, email); err != nil {
		t.Fatalf("create test user: %v", err)
	}
	return userID
}

func deleteTestFamiliesAndUsers(t *testing.T, pool *pgxpool.Pool, userIDs ...uuid.UUID) {
	t.Helper()
	if _, err := pool.Exec(context.Background(), "delete from families where created_by = any($1)", userIDs); err != nil {
		t.Errorf("delete test families: %v", err)
	}
	if _, err := pool.Exec(context.Background(), "delete from users where id = any($1)", userIDs); err != nil {
		t.Errorf("delete test users: %v", err)
	}
}

func inviteFamilyID(t *testing.T, pool *pgxpool.Pool, code string, secret []byte) uuid.UUID {
	t.Helper()
	var familyID uuid.UUID
	if err := pool.QueryRow(context.Background(), "select family_id from partner_invites where code_digest = $1", digestInviteCode(secret, code)).Scan(&familyID); err != nil {
		t.Fatalf("get invite family: %v", err)
	}
	return familyID
}
