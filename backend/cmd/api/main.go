package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/vgpl2000/Sitaara/backend/internal/auth"
	"github.com/vgpl2000/Sitaara/backend/internal/content"
	"github.com/vgpl2000/Sitaara/backend/internal/family"
	"github.com/vgpl2000/Sitaara/backend/internal/httpapi"
	"github.com/vgpl2000/Sitaara/backend/internal/platform/app"
	"github.com/vgpl2000/Sitaara/backend/internal/platform/config"
	"github.com/vgpl2000/Sitaara/backend/internal/platform/logging"
	"github.com/vgpl2000/Sitaara/backend/internal/postgres"
)

var version = "dev"

func main() {
	os.Exit(run())
}

func run() int {
	bootstrapLogger := logging.New(slog.LevelInfo, version, "unknown")

	cfg, err := config.Load()
	if err != nil {
		bootstrapLogger.Error("configuration rejected", "error", err)
		return 1
	}

	logger := logging.New(cfg.LogLevel, version, cfg.Environment)
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := postgres.Open(ctx, cfg.DatabaseURL, postgres.PoolOptions{
		MaxConnections: cfg.DBMaxConnections,
		ConnectTimeout: cfg.DBConnectTimeout,
	})
	if err != nil {
		logger.Error("database connection failed", "error", err)
		return 1
	}

	passwordHasher := auth.NewPasswordHasher(auth.DefaultPasswordParams(), 2)
	accessTokens := auth.NewAccessTokenManager(
		cfg.JWTSecret,
		cfg.JWTIssuer,
		cfg.JWTAudience,
		cfg.AccessTokenTTL,
		time.Now,
	)
	authService, err := auth.NewService(ctx, auth.ServiceOptions{
		Pool:          pool,
		Hasher:        passwordHasher,
		AccessTokens:  accessTokens,
		RefreshSecret: cfg.RefreshHMACSecret,
		RefreshTTL:    cfg.RefreshTokenTTL,
		Now:           time.Now,
	})
	if err != nil {
		pool.Close()
		logger.Error("authentication service initialization failed", "error_type", fmt.Sprintf("%T", err))
		return 1
	}
	familyService := family.NewService(pool, cfg.InviteHMACSecret, time.Now)
	contentService := content.NewService(pool)

	server := httpapi.NewServer(httpapi.ServerOptions{
		Address:             cfg.Address(),
		Logger:              logger,
		ReadyChecker:        pool,
		ReadyTimeout:        cfg.DBPingTimeout,
		ReadHeaderTimeout:   cfg.HTTPReadHeaderTimeout,
		ReadTimeout:         cfg.HTTPReadTimeout,
		WriteTimeout:        cfg.HTTPWriteTimeout,
		IdleTimeout:         cfg.HTTPIdleTimeout,
		MaxRequestBodyBytes: cfg.MaxRequestBodyBytes,
		AuthService:         authService,
		AccessTokens:        accessTokens,
		FamilyService:       familyService,
		ContentService:      contentService,
	})

	logger.Info("api starting", "address", cfg.Address())
	err = app.Run(ctx, server, cfg.ShutdownTimeout, pool)
	if err != nil && !errors.Is(err, context.Canceled) {
		logger.Error("api stopped with error", "error", err)
		return 1
	}

	logger.Info("api stopped")
	return 0
}
