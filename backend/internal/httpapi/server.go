package httpapi

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
)

type ReadyChecker interface {
	Ping(context.Context) error
}

type ServerOptions struct {
	Address             string
	Logger              *slog.Logger
	ReadyChecker        ReadyChecker
	ReadyTimeout        time.Duration
	ReadHeaderTimeout   time.Duration
	ReadTimeout         time.Duration
	WriteTimeout        time.Duration
	IdleTimeout         time.Duration
	MaxRequestBodyBytes int64
}

func NewServer(options ServerOptions) *http.Server {
	router := NewHandler(options.Logger, options.ReadyChecker, options.ReadyTimeout, options.MaxRequestBodyBytes)
	return &http.Server{
		Addr:              options.Address,
		Handler:           router,
		ReadHeaderTimeout: options.ReadHeaderTimeout,
		ReadTimeout:       options.ReadTimeout,
		WriteTimeout:      options.WriteTimeout,
		IdleTimeout:       options.IdleTimeout,
	}
}

func NewHandler(logger *slog.Logger, ready ReadyChecker, readyTimeout time.Duration, maxBodyBytes int64) http.Handler {
	router := chi.NewRouter()
	router.Use(requestIDMiddleware)
	router.Use(requestLoggingMiddleware(logger))
	router.Use(recoveryMiddleware(logger))
	router.Use(requestBodyLimitMiddleware(maxBodyBytes))

	router.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeData(w, r, http.StatusOK, map[string]string{"status": "ok"})
	})

	router.Get("/readyz", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), readyTimeout)
		defer cancel()

		if err := ready.Ping(ctx); err != nil {
			writeError(w, r, http.StatusServiceUnavailable, "SERVICE_UNAVAILABLE", "Service is not ready.")
			return
		}

		writeData(w, r, http.StatusOK, map[string]string{"status": "ready"})
	})

	return router
}
