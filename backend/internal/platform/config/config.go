package config

import (
	"errors"
	"fmt"
	"log/slog"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

const (
	LocalEnvironment      = "local"
	TestEnvironment       = "test"
	ProductionEnvironment = "production"
)

type Config struct {
	Environment           string
	Port                  int
	DatabaseURL           string
	LogLevel              slog.Level
	DBMaxConnections      int32
	DBConnectTimeout      time.Duration
	DBPingTimeout         time.Duration
	ShutdownTimeout       time.Duration
	HTTPReadHeaderTimeout time.Duration
	HTTPReadTimeout       time.Duration
	HTTPWriteTimeout      time.Duration
	HTTPIdleTimeout       time.Duration
	MaxRequestBodyBytes   int64
}

type LookupFunc func(string) (string, bool)

func Load() (Config, error) {
	return LoadFrom(os.LookupEnv)
}

func LoadFrom(lookup LookupFunc) (Config, error) {
	cfg := Config{
		Environment:           valueOrDefault(lookup, "APP_ENV", LocalEnvironment),
		Port:                  8080,
		DatabaseURL:           strings.TrimSpace(value(lookup, "DATABASE_URL")),
		LogLevel:              slog.LevelInfo,
		DBMaxConnections:      5,
		DBConnectTimeout:      5 * time.Second,
		DBPingTimeout:         2 * time.Second,
		ShutdownTimeout:       10 * time.Second,
		HTTPReadHeaderTimeout: 5 * time.Second,
		HTTPReadTimeout:       15 * time.Second,
		HTTPWriteTimeout:      30 * time.Second,
		HTTPIdleTimeout:       60 * time.Second,
		MaxRequestBodyBytes:   1 << 20,
	}

	var errs []error

	switch cfg.Environment {
	case LocalEnvironment, TestEnvironment, ProductionEnvironment:
	default:
		errs = append(errs, fmt.Errorf("APP_ENV must be local, test, or production"))
	}

	if raw := strings.TrimSpace(value(lookup, "PORT")); raw != "" {
		port, err := strconv.Atoi(raw)
		if err != nil || port < 1 || port > 65535 {
			errs = append(errs, fmt.Errorf("PORT must be an integer between 1 and 65535"))
		} else {
			cfg.Port = port
		}
	}

	if cfg.DatabaseURL == "" {
		errs = append(errs, fmt.Errorf("DATABASE_URL is required"))
	} else if err := validateDatabaseURL(cfg.DatabaseURL, cfg.Environment); err != nil {
		errs = append(errs, err)
	}

	if raw := strings.TrimSpace(value(lookup, "LOG_LEVEL")); raw != "" {
		level, err := parseLogLevel(raw)
		if err != nil {
			errs = append(errs, err)
		} else {
			cfg.LogLevel = level
		}
	}

	if raw := strings.TrimSpace(value(lookup, "DB_MAX_CONNECTIONS")); raw != "" {
		connections, err := strconv.ParseInt(raw, 10, 32)
		if err != nil || connections < 1 || connections > 50 {
			errs = append(errs, fmt.Errorf("DB_MAX_CONNECTIONS must be between 1 and 50"))
		} else {
			cfg.DBMaxConnections = int32(connections)
		}
	}

	if err := errors.Join(errs...); err != nil {
		return Config{}, err
	}

	return cfg, nil
}

func (c Config) Address() string {
	return fmt.Sprintf(":%d", c.Port)
}

func validateDatabaseURL(raw, environment string) error {
	parsed, err := url.Parse(raw)
	if err != nil || parsed.Host == "" {
		return fmt.Errorf("DATABASE_URL must be a valid PostgreSQL URL")
	}

	if parsed.Scheme != "postgres" && parsed.Scheme != "postgresql" {
		return fmt.Errorf("DATABASE_URL must use the postgres or postgresql scheme")
	}

	if environment != ProductionEnvironment {
		return nil
	}

	switch strings.ToLower(parsed.Query().Get("sslmode")) {
	case "require", "verify-ca", "verify-full":
		return nil
	default:
		return fmt.Errorf("production DATABASE_URL must require TLS")
	}
}

func parseLogLevel(raw string) (slog.Level, error) {
	switch strings.ToLower(raw) {
	case "debug":
		return slog.LevelDebug, nil
	case "info":
		return slog.LevelInfo, nil
	case "warn", "warning":
		return slog.LevelWarn, nil
	case "error":
		return slog.LevelError, nil
	default:
		return 0, fmt.Errorf("LOG_LEVEL must be debug, info, warn, or error")
	}
}

func value(lookup LookupFunc, name string) string {
	result, _ := lookup(name)
	return result
}

func valueOrDefault(lookup LookupFunc, name, fallback string) string {
	if result := strings.TrimSpace(value(lookup, name)); result != "" {
		return result
	}
	return fallback
}
