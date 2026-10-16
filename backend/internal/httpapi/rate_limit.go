package httpapi

import (
	"net"
	"net/http"
	"sync"
	"time"

	"golang.org/x/time/rate"
)

type clientLimitEntry struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

type clientLimiter struct {
	mu      sync.Mutex
	clients map[string]clientLimitEntry
	limit   rate.Limit
	burst   int
	now     func() time.Time
}

func newClientLimiter(requests int, interval time.Duration) *clientLimiter {
	return &clientLimiter{
		clients: make(map[string]clientLimitEntry),
		limit:   rate.Every(interval / time.Duration(requests)),
		burst:   requests,
		now:     time.Now,
	}
}

func (l *clientLimiter) middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !l.allow(clientAddress(r)) {
			w.Header().Set("Retry-After", "60")
			writeError(w, r, http.StatusTooManyRequests, "RATE_LIMITED", "Too many attempts. Please try again shortly.")
			return
		}
		next.ServeHTTP(w, r)
	})
}

func (l *clientLimiter) allow(client string) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := l.now()
	entry, exists := l.clients[client]
	if !exists {
		entry = clientLimitEntry{limiter: rate.NewLimiter(l.limit, l.burst)}
	}
	entry.lastSeen = now
	l.clients[client] = entry

	if len(l.clients) > 10_000 {
		for key, candidate := range l.clients {
			if now.Sub(candidate.lastSeen) > 10*time.Minute {
				delete(l.clients, key)
			}
		}
	}
	return entry.limiter.Allow()
}

func clientAddress(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil {
		return host
	}
	return r.RemoteAddr
}
