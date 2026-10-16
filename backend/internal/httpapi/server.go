package httpapi

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/vgpl2000/Sitaara/backend/internal/auth"
	"github.com/vgpl2000/Sitaara/backend/internal/content"
	"github.com/vgpl2000/Sitaara/backend/internal/family"
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
	AuthService         *auth.Service
	AccessTokens        *auth.AccessTokenManager
	FamilyService       *family.Service
	ContentService      *content.Service
}

type HandlerOptions struct {
	Logger              *slog.Logger
	ReadyChecker        ReadyChecker
	ReadyTimeout        time.Duration
	MaxRequestBodyBytes int64
	AuthService         *auth.Service
	AccessTokens        *auth.AccessTokenManager
	FamilyService       *family.Service
	ContentService      *content.Service
}

func NewServer(options ServerOptions) *http.Server {
	router := NewHandler(HandlerOptions{
		Logger:              options.Logger,
		ReadyChecker:        options.ReadyChecker,
		ReadyTimeout:        options.ReadyTimeout,
		MaxRequestBodyBytes: options.MaxRequestBodyBytes,
		AuthService:         options.AuthService,
		AccessTokens:        options.AccessTokens,
		FamilyService:       options.FamilyService,
		ContentService:      options.ContentService,
	})
	return &http.Server{
		Addr:              options.Address,
		Handler:           router,
		ReadHeaderTimeout: options.ReadHeaderTimeout,
		ReadTimeout:       options.ReadTimeout,
		WriteTimeout:      options.WriteTimeout,
		IdleTimeout:       options.IdleTimeout,
	}
}

func NewHandler(options HandlerOptions) http.Handler {
	router := chi.NewRouter()
	router.Use(requestIDMiddleware)
	router.Use(requestLoggingMiddleware(options.Logger))
	router.Use(recoveryMiddleware(options.Logger))
	router.Use(requestBodyLimitMiddleware(options.MaxRequestBodyBytes))

	router.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeData(w, r, http.StatusOK, map[string]string{"status": "ok"})
	})

	router.Get("/readyz", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), options.ReadyTimeout)
		defer cancel()

		if err := options.ReadyChecker.Ping(ctx); err != nil {
			writeError(w, r, http.StatusServiceUnavailable, "SERVICE_UNAVAILABLE", "Service is not ready.")
			return
		}

		writeData(w, r, http.StatusOK, map[string]string{"status": "ready"})
	})

	if options.AuthService != nil && options.AccessTokens != nil {
		authHandler := newAuthHandler(options.Logger, options.AuthService, options.FamilyService)
		registerLimiter := newClientLimiter(5, time.Minute)
		loginLimiter := newClientLimiter(10, time.Minute)
		refreshLimiter := newClientLimiter(20, time.Minute)

		router.Route("/v1", func(versioned chi.Router) {
			versioned.Route("/auth", func(authRouter chi.Router) {
				authRouter.With(registerLimiter.middleware).Post("/register", authHandler.register)
				authRouter.With(loginLimiter.middleware).Post("/login", authHandler.login)
				authRouter.With(refreshLimiter.middleware).Post("/refresh", authHandler.refresh)
				authRouter.With(authenticationMiddleware(options.AccessTokens)).Post("/logout", authHandler.logout)
			})
			versioned.With(authenticationMiddleware(options.AccessTokens)).Get("/me", authHandler.me)
			if options.FamilyService != nil {
				familyHandler := newFamilyHandler(options.Logger, options.FamilyService)
				redeemLimiter := newClientLimiter(10, time.Minute)
				versioned.Group(func(protected chi.Router) {
					protected.Use(authenticationMiddleware(options.AccessTokens))
					protected.Post("/families", familyHandler.create)
					protected.Get("/family", familyHandler.get)
					protected.Post("/invites", familyHandler.createInvite)
					protected.With(redeemLimiter.middleware).Post("/invites/redeem", familyHandler.redeemInvite)
				})
			}
			if options.ContentService != nil {
				contentHandler := newContentHandler(options.Logger, options.ContentService)
				versioned.Group(func(protected chi.Router) {
					protected.Use(authenticationMiddleware(options.AccessTokens))
					protected.Get("/masterclasses", contentHandler.listMasterclasses)
					protected.Get("/masterclasses/{masterclassId}", contentHandler.getMasterclass)
					protected.Get("/videos/{videoId}", contentHandler.getVideo)
					protected.Put("/videos/{videoId}/like", contentHandler.likeVideo)
					protected.Delete("/videos/{videoId}/like", contentHandler.unlikeVideo)
					protected.Put("/videos/{videoId}/progress", contentHandler.updateProgress)
				})
			}
		})
	}

	return router
}
