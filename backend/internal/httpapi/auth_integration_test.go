//go:build integration

package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/vgpl2000/Sitaara/backend/internal/auth"
	"github.com/vgpl2000/Sitaara/backend/internal/content"
	"github.com/vgpl2000/Sitaara/backend/internal/family"
)

func TestAuthHTTPFlow(t *testing.T) {
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
	tokens := auth.NewAccessTokenManager(
		[]byte(strings.Repeat("a", 32)),
		"test-issuer",
		"test-audience",
		15*time.Minute,
		now,
	)
	service, err := auth.NewService(context.Background(), auth.ServiceOptions{
		Pool: pool,
		Hasher: auth.NewPasswordHasher(auth.PasswordParams{
			MemoryKiB:   64,
			Iterations:  1,
			Parallelism: 1,
			SaltLength:  16,
			KeyLength:   32,
		}, 1),
		AccessTokens:  tokens,
		RefreshSecret: []byte(strings.Repeat("r", 32)),
		RefreshTTL:    time.Hour,
		Now:           now,
	})
	if err != nil {
		t.Fatalf("NewService returned error: %v", err)
	}
	familyService := family.NewService(pool, []byte(strings.Repeat("i", 32)), now)
	contentService := content.NewService(pool)

	handler := NewHandler(HandlerOptions{
		Logger:              slog.New(slog.NewJSONHandler(io.Discard, nil)),
		ReadyChecker:        pool,
		ReadyTimeout:        time.Second,
		MaxRequestBodyBytes: 4096,
		AuthService:         service,
		AccessTokens:        tokens,
		FamilyService:       familyService,
		ContentService:      contentService,
	})

	email := fmt.Sprintf("http-flow-%d@example.test", time.Now().UnixNano())
	partnerEmail := fmt.Sprintf("http-partner-%d@example.test", time.Now().UnixNano())
	t.Cleanup(func() {
		if _, cleanupErr := pool.Exec(context.Background(), "delete from families where created_by = (select id from users where email = $1)", email); cleanupErr != nil {
			t.Errorf("delete test family: %v", cleanupErr)
		}
		if _, cleanupErr := pool.Exec(context.Background(), "delete from users where email::text = any($1::text[])", []string{email, partnerEmail}); cleanupErr != nil {
			t.Errorf("delete test user: %v", cleanupErr)
		}
	})

	register := performJSON(handler, http.MethodPost, "/v1/auth/register", fmt.Sprintf(`{"email":%q,"password":"password 123"}`, email), "")
	if register.Code != http.StatusCreated {
		t.Fatalf("register status = %d, body = %s", register.Code, register.Body.String())
	}
	registered := decodeSessionResponse(t, register)

	duplicate := performJSON(handler, http.MethodPost, "/v1/auth/register", fmt.Sprintf(`{"email":%q,"password":"password 123"}`, strings.ToUpper(email)), "")
	assertErrorCode(t, duplicate, http.StatusConflict, "EMAIL_ALREADY_USED")

	invalidLogin := performJSON(handler, http.MethodPost, "/v1/auth/login", fmt.Sprintf(`{"email":%q,"password":"incorrect"}`, email), "")
	assertErrorCode(t, invalidLogin, http.StatusUnauthorized, "INVALID_CREDENTIALS")

	unknownField := performJSON(handler, http.MethodPost, "/v1/auth/login", fmt.Sprintf(`{"email":%q,"password":"password 123","userId":"forbidden"}`, email), "")
	assertErrorCode(t, unknownField, http.StatusBadRequest, "VALIDATION_ERROR")

	me := performJSON(handler, http.MethodGet, "/v1/me", "", registered.AccessToken)
	if me.Code != http.StatusOK {
		t.Fatalf("me status = %d, body = %s", me.Code, me.Body.String())
	}
	var meBody struct {
		Data struct {
			Email           string `json:"email"`
			OnboardingState string `json:"onboardingState"`
			Family          any    `json:"family"`
		} `json:"data"`
	}
	if err := json.Unmarshal(me.Body.Bytes(), &meBody); err != nil {
		t.Fatalf("decode me response: %v", err)
	}
	if meBody.Data.Email != email || meBody.Data.OnboardingState != "needs_family" || meBody.Data.Family != nil {
		t.Fatalf("me response = %#v", meBody.Data)
	}

	createdFamily := performJSON(handler, http.MethodPost, "/v1/families", `{"role":"mom","child":{"name":"Aarav","dateOfBirth":"2024-04-12"}}`, registered.AccessToken)
	if createdFamily.Code != http.StatusCreated {
		t.Fatalf("create family status = %d, body = %s", createdFamily.Code, createdFamily.Body.String())
	}
	inviteResponse := performJSON(handler, http.MethodPost, "/v1/invites", `{}`, registered.AccessToken)
	if inviteResponse.Code != http.StatusCreated {
		t.Fatalf("create invite status = %d, body = %s", inviteResponse.Code, inviteResponse.Body.String())
	}
	var inviteBody struct {
		Data struct {
			Code string `json:"code"`
		} `json:"data"`
	}
	if err := json.Unmarshal(inviteResponse.Body.Bytes(), &inviteBody); err != nil || inviteBody.Data.Code == "" {
		t.Fatalf("decode invite response: %v", err)
	}

	partnerRegister := performJSON(handler, http.MethodPost, "/v1/auth/register", fmt.Sprintf(`{"email":%q,"password":"password 123"}`, partnerEmail), "")
	if partnerRegister.Code != http.StatusCreated {
		t.Fatalf("partner register status = %d, body = %s", partnerRegister.Code, partnerRegister.Body.String())
	}
	partnerSession := decodeSessionResponse(t, partnerRegister)
	join := performJSON(handler, http.MethodPost, "/v1/invites/redeem", fmt.Sprintf(`{"code":%q,"role":"dad"}`, inviteBody.Data.Code), partnerSession.AccessToken)
	if join.Code != http.StatusOK {
		t.Fatalf("redeem invite status = %d, body = %s", join.Code, join.Body.String())
	}
	partnerMe := performJSON(handler, http.MethodGet, "/v1/me", "", partnerSession.AccessToken)
	if partnerMe.Code != http.StatusOK || !bytes.Contains(partnerMe.Body.Bytes(), []byte(`"onboardingState":"onboarded"`)) {
		t.Fatalf("partner me status = %d, body = %s", partnerMe.Code, partnerMe.Body.String())
	}

	videoID := "11000000-0000-4000-8000-000000000001"
	like := performJSON(handler, http.MethodPut, "/v1/videos/"+videoID+"/like", "", registered.AccessToken)
	if like.Code != http.StatusOK {
		t.Fatalf("like status = %d, body = %s", like.Code, like.Body.String())
	}
	progress := performJSON(handler, http.MethodPut, "/v1/videos/"+videoID+"/progress", `{"positionSeconds":30}`, registered.AccessToken)
	if progress.Code != http.StatusOK {
		t.Fatalf("progress status = %d, body = %s", progress.Code, progress.Body.String())
	}
	partnerVideo := performJSON(handler, http.MethodGet, "/v1/videos/"+videoID, "", partnerSession.AccessToken)
	if partnerVideo.Code != http.StatusOK ||
		!bytes.Contains(partnerVideo.Body.Bytes(), []byte(`"role":"mom"`)) ||
		!bytes.Contains(partnerVideo.Body.Bytes(), []byte(`"furthestSeconds":30`)) ||
		!bytes.Contains(partnerVideo.Body.Bytes(), []byte(`"liked":true`)) ||
		!bytes.Contains(partnerVideo.Body.Bytes(), []byte(`"isCurrentlyWatching":true`)) {
		t.Fatalf("partner video status = %d, body = %s", partnerVideo.Code, partnerVideo.Body.String())
	}

	logout := performJSON(handler, http.MethodPost, "/v1/auth/logout", fmt.Sprintf(`{"refreshToken":%q}`, registered.RefreshToken), registered.AccessToken)
	if logout.Code != http.StatusNoContent || logout.Body.Len() != 0 {
		t.Fatalf("logout status = %d, body = %s", logout.Code, logout.Body.String())
	}

	refresh := performJSON(handler, http.MethodPost, "/v1/auth/refresh", fmt.Sprintf(`{"refreshToken":%q}`, registered.RefreshToken), "")
	assertErrorCode(t, refresh, http.StatusUnauthorized, "INVALID_REFRESH_TOKEN")
}

type sessionResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}

func decodeSessionResponse(t *testing.T, response *httptest.ResponseRecorder) sessionResponse {
	t.Helper()
	var body struct {
		Data sessionResponse `json:"data"`
	}
	if err := json.Unmarshal(response.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode session response: %v", err)
	}
	if body.Data.AccessToken == "" || body.Data.RefreshToken == "" {
		t.Fatal("session response does not contain both tokens")
	}
	return body.Data
}

func performJSON(handler http.Handler, method, path, body, accessToken string) *httptest.ResponseRecorder {
	request := httptest.NewRequest(method, path, bytes.NewBufferString(body))
	request.Header.Set("Content-Type", "application/json")
	request.RemoteAddr = "192.0.2.10:12345"
	if accessToken != "" {
		request.Header.Set("Authorization", "Bearer "+accessToken)
	}
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, request)
	return response
}

func assertErrorCode(t *testing.T, response *httptest.ResponseRecorder, status int, code string) {
	t.Helper()
	if response.Code != status {
		t.Fatalf("status = %d, want %d; body = %s", response.Code, status, response.Body.String())
	}
	var body responseEnvelope
	if err := json.Unmarshal(response.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode error response: %v", err)
	}
	if body.Error == nil || body.Error.Code != code {
		t.Fatalf("error = %#v, want %q", body.Error, code)
	}
}
