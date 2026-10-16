package httpapi

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestClientLimiterRejectsRequestsAboveBurst(t *testing.T) {
	limiter := newClientLimiter(2, time.Minute)
	limiter.now = func() time.Time { return time.Date(2026, time.October, 16, 12, 0, 0, 0, time.UTC) }
	handler := requestIDMiddleware(limiter.middleware(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})))

	for attempt := 1; attempt <= 3; attempt++ {
		request := httptest.NewRequest(http.MethodPost, "/", nil)
		request.RemoteAddr = "192.0.2.20:12345"
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, request)

		expected := http.StatusNoContent
		if attempt == 3 {
			expected = http.StatusTooManyRequests
		}
		if response.Code != expected {
			t.Fatalf("attempt %d status = %d, want %d", attempt, response.Code, expected)
		}
	}
}
