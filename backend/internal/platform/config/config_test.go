package config

import (
	"strings"
	"testing"
)

func TestLoadFromUsesSafeLocalDefaults(t *testing.T) {
	cfg, err := LoadFrom(mapLookup(map[string]string{
		"DATABASE_URL": "postgres://postgres:secret@127.0.0.1:5432/sitaara?sslmode=disable",
	}))
	if err != nil {
		t.Fatalf("LoadFrom returned error: %v", err)
	}

	if cfg.Environment != LocalEnvironment {
		t.Fatalf("environment = %q, want %q", cfg.Environment, LocalEnvironment)
	}
	if cfg.Port != 8080 {
		t.Fatalf("port = %d, want 8080", cfg.Port)
	}
	if cfg.DBMaxConnections != 5 {
		t.Fatalf("max connections = %d, want 5", cfg.DBMaxConnections)
	}
}

func TestLoadFromRejectsMissingDatabaseURL(t *testing.T) {
	_, err := LoadFrom(mapLookup(nil))
	if err == nil || !strings.Contains(err.Error(), "DATABASE_URL is required") {
		t.Fatalf("error = %v, want missing DATABASE_URL", err)
	}
}

func TestLoadFromRejectsUnsafeProductionDatabaseURL(t *testing.T) {
	_, err := LoadFrom(mapLookup(map[string]string{
		"APP_ENV":      ProductionEnvironment,
		"DATABASE_URL": "postgres://db.example.test/sitaara?sslmode=disable",
	}))
	if err == nil || !strings.Contains(err.Error(), "must require TLS") {
		t.Fatalf("error = %v, want TLS validation error", err)
	}
}

func TestLoadFromAcceptsProductionTLS(t *testing.T) {
	_, err := LoadFrom(mapLookup(map[string]string{
		"APP_ENV":      ProductionEnvironment,
		"DATABASE_URL": "postgres://db.example.test/sitaara?sslmode=verify-full",
	}))
	if err != nil {
		t.Fatalf("LoadFrom returned error: %v", err)
	}
}

func TestLoadFromCollectsInvalidValues(t *testing.T) {
	_, err := LoadFrom(mapLookup(map[string]string{
		"APP_ENV":            "staging",
		"PORT":               "70000",
		"DATABASE_URL":       "mysql://localhost/db",
		"LOG_LEVEL":          "verbose",
		"DB_MAX_CONNECTIONS": "0",
	}))
	if err == nil {
		t.Fatal("LoadFrom returned nil error")
	}

	for _, expected := range []string{"APP_ENV", "PORT", "DATABASE_URL", "LOG_LEVEL", "DB_MAX_CONNECTIONS"} {
		if !strings.Contains(err.Error(), expected) {
			t.Errorf("error %q does not contain %q", err, expected)
		}
	}
}

func mapLookup(values map[string]string) LookupFunc {
	return func(name string) (string, bool) {
		value, ok := values[name]
		return value, ok
	}
}
