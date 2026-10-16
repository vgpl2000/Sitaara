package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestHealthDoesNotCallDatabase(t *testing.T) {
	checker := &fakeReadyChecker{err: errors.New("database unavailable")}
	handler := testHandler(checker)

	request := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", response.Code)
	}
	if checker.calls != 0 {
		t.Fatalf("database calls = %d, want 0", checker.calls)
	}
	assertRequestID(t, response)
}

func TestReadyReturnsOKWhenDatabaseIsReachable(t *testing.T) {
	checker := &fakeReadyChecker{}
	handler := testHandler(checker)

	request := httptest.NewRequest(http.MethodGet, "/readyz", nil)
	request.Header.Set("X-Request-ID", "test-request-123")
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", response.Code)
	}
	if response.Header().Get("X-Request-ID") != "test-request-123" {
		t.Fatalf("request ID = %q", response.Header().Get("X-Request-ID"))
	}
}

func TestReadyReturnsSafeFailure(t *testing.T) {
	checker := &fakeReadyChecker{err: errors.New("password authentication failed for secret-user")}
	handler := testHandler(checker)

	request := httptest.NewRequest(http.MethodGet, "/readyz", nil)
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, request)

	if response.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want 503", response.Code)
	}
	if bytes.Contains(response.Body.Bytes(), []byte("secret-user")) {
		t.Fatal("response leaked dependency details")
	}

	var body responseEnvelope
	if err := json.Unmarshal(response.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.Error == nil || body.Error.Code != "SERVICE_UNAVAILABLE" {
		t.Fatalf("error = %#v", body.Error)
	}
}

func TestRequestLogDoesNotContainSensitiveRequestData(t *testing.T) {
	var logs bytes.Buffer
	logger := slog.New(slog.NewJSONHandler(&logs, nil))
	handler := NewHandler(logger, &fakeReadyChecker{}, 100*time.Millisecond, 1024)

	request := httptest.NewRequest(
		http.MethodPost,
		"/missing?token=query-secret",
		bytes.NewBufferString(`{"password":"body-secret"}`),
	)
	request.Header.Set("Authorization", "Bearer header-secret")
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, request)

	for _, secret := range []string{"query-secret", "body-secret", "header-secret"} {
		if bytes.Contains(logs.Bytes(), []byte(secret)) {
			t.Fatalf("request log contains sensitive value %q", secret)
		}
	}
	if !bytes.Contains(logs.Bytes(), []byte(`"request_id"`)) {
		t.Fatal("request log does not contain a request ID")
	}
}

func testHandler(checker ReadyChecker) http.Handler {
	logger := slog.New(slog.NewTextHandler(io.Discard, nil))
	return NewHandler(logger, checker, 100*time.Millisecond, 1024)
}

func assertRequestID(t *testing.T, response *httptest.ResponseRecorder) {
	t.Helper()
	if response.Header().Get("X-Request-ID") == "" {
		t.Fatal("response does not contain X-Request-ID")
	}
}

type fakeReadyChecker struct {
	err   error
	calls int
}

func (f *fakeReadyChecker) Ping(context.Context) error {
	f.calls++
	return f.err
}
