//go:build integration

package auth

import (
	"context"
	"errors"
	"fmt"
	"os"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

func TestRegistrationLoginRefreshLogoutLifecycle(t *testing.T) {
	service, pool := integrationService(t)
	email := uniqueTestEmail("lifecycle")
	t.Cleanup(func() { deleteTestUser(t, pool, email) })

	registered, err := service.Register(context.Background(), "  "+strings.ToUpper(email)+"  ", "password 123")
	if err != nil {
		t.Fatalf("Register returned error: %v", err)
	}
	if registered.User.Email != email || registered.RefreshToken == "" || registered.AccessToken == "" {
		t.Fatalf("registered session is incomplete: %#v", registered)
	}
	var storedPasswordHash, storedRefreshDigest string
	if err := pool.QueryRow(
		context.Background(),
		`select u.password_hash, s.token_digest
		 from users u
		 join refresh_sessions s on s.user_id = u.id
		 where u.email = $1
		 order by s.created_at
		 limit 1`,
		email,
	).Scan(&storedPasswordHash, &storedRefreshDigest); err != nil {
		t.Fatalf("inspect stored credentials: %v", err)
	}
	if !strings.HasPrefix(storedPasswordHash, "$argon2id$") || strings.Contains(storedPasswordHash, "password 123") {
		t.Fatal("database does not contain a safe Argon2id password representation")
	}
	if storedRefreshDigest == registered.RefreshToken || strings.Contains(storedRefreshDigest, registered.RefreshToken) {
		t.Fatal("database contains the raw refresh token")
	}

	if _, err := service.Register(context.Background(), email, "password 123"); !errors.Is(err, ErrEmailAlreadyUsed) {
		t.Fatalf("duplicate registration error = %v", err)
	}
	if _, err := service.Login(context.Background(), email, "wrong password"); !errors.Is(err, ErrInvalidCredentials) {
		t.Fatalf("wrong password error = %v", err)
	}

	loggedIn, err := service.Login(context.Background(), email, "password 123")
	if err != nil {
		t.Fatalf("Login returned error: %v", err)
	}
	rotated, err := service.Refresh(context.Background(), loggedIn.RefreshToken)
	if err != nil {
		t.Fatalf("Refresh returned error: %v", err)
	}
	if rotated.RefreshToken == loggedIn.RefreshToken {
		t.Fatal("refresh token was not rotated")
	}

	principal, err := service.accessTokens.Validate(rotated.AccessToken)
	if err != nil {
		t.Fatalf("validate rotated access token: %v", err)
	}
	current, err := service.GetMe(context.Background(), principal.UserID)
	if err != nil {
		t.Fatalf("GetMe returned error: %v", err)
	}
	if current.Email != email || current.OnboardingState != "needs_family" || current.Family != nil {
		t.Fatalf("current user = %#v", current)
	}

	if err := service.Logout(context.Background(), principal, rotated.RefreshToken); err != nil {
		t.Fatalf("Logout returned error: %v", err)
	}
	if err := service.Logout(context.Background(), principal, rotated.RefreshToken); err != nil {
		t.Fatalf("idempotent Logout returned error: %v", err)
	}
	if _, err := service.Refresh(context.Background(), rotated.RefreshToken); !errors.Is(err, ErrInvalidRefreshToken) {
		t.Fatalf("refresh after logout error = %v", err)
	}
}

func TestConcurrentRefreshDetectsReuseAndRevokesFamily(t *testing.T) {
	service, pool := integrationService(t)
	email := uniqueTestEmail("concurrent-refresh")
	t.Cleanup(func() { deleteTestUser(t, pool, email) })

	registered, err := service.Register(context.Background(), email, "password 123")
	if err != nil {
		t.Fatalf("Register returned error: %v", err)
	}

	type result struct {
		session Session
		err     error
	}
	start := make(chan struct{})
	results := make(chan result, 2)
	var workers sync.WaitGroup
	for range 2 {
		workers.Add(1)
		go func() {
			defer workers.Done()
			<-start
			session, refreshErr := service.Refresh(context.Background(), registered.RefreshToken)
			results <- result{session: session, err: refreshErr}
		}()
	}
	close(start)
	workers.Wait()
	close(results)

	var successful Session
	successCount := 0
	reuseCount := 0
	for outcome := range results {
		switch {
		case outcome.err == nil:
			successCount++
			successful = outcome.session
		case errors.Is(outcome.err, ErrSessionReused):
			reuseCount++
		default:
			t.Fatalf("unexpected refresh error: %v", outcome.err)
		}
	}
	if successCount != 1 || reuseCount != 1 {
		t.Fatalf("successes = %d, reuse errors = %d", successCount, reuseCount)
	}
	if _, err := service.Refresh(context.Background(), successful.RefreshToken); !errors.Is(err, ErrInvalidRefreshToken) {
		t.Fatalf("successor after reuse error = %v", err)
	}
	principal, err := service.accessTokens.Validate(successful.AccessToken)
	if err != nil {
		t.Fatalf("validate successful access token: %v", err)
	}
	var activeSessions int
	if err := pool.QueryRow(
		context.Background(),
		"select count(*) from refresh_sessions where family_id = $1 and revoked_at is null",
		principal.SessionFamily,
	).Scan(&activeSessions); err != nil {
		t.Fatalf("count active refresh sessions: %v", err)
	}
	if activeSessions != 0 {
		t.Fatalf("active refresh sessions after reuse = %d, want 0", activeSessions)
	}
}

func integrationService(t *testing.T) (*Service, *pgxpool.Pool) {
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

	now := time.Now
	tokens := NewAccessTokenManager([]byte(strings.Repeat("a", 32)), "test-issuer", "test-audience", 15*time.Minute, now)
	service, err := NewService(context.Background(), ServiceOptions{
		Pool:          pool,
		Hasher:        testPasswordHasher(),
		AccessTokens:  tokens,
		RefreshSecret: []byte(strings.Repeat("r", 32)),
		RefreshTTL:    time.Hour,
		Now:           now,
	})
	if err != nil {
		t.Fatalf("NewService returned error: %v", err)
	}
	return service, pool
}

func uniqueTestEmail(prefix string) string {
	return fmt.Sprintf("%s-%d@example.test", prefix, time.Now().UnixNano())
}

func deleteTestUser(t *testing.T, pool *pgxpool.Pool, email string) {
	t.Helper()
	if _, err := pool.Exec(context.Background(), "delete from users where email = $1", email); err != nil {
		t.Errorf("delete test user: %v", err)
	}
}
