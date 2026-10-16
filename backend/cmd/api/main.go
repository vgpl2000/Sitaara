package main

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

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
