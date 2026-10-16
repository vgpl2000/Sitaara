package logging

import (
	"log/slog"
	"os"
)

func New(level slog.Level, version, environment string) *slog.Logger {
	handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: level})
	return slog.New(handler).With(
		"service", "sitaara-api",
		"version", version,
		"environment", environment,
	)
}
