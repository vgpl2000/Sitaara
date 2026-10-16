package config

import (
	"strings"
	"testing"
)

func TestLoadFromUsesSafeLocalDefaults(t *testing.T) {
	cfg, err := LoadFrom(mapLookup(withAuthConfig(map[string]string{
		"DATABASE_URL": "postgres://postgres:secret@127.0.0.1:5432/sitaara?sslmode=disable",
	})))
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
	_, err := LoadFrom(mapLookup(withAuthConfig(nil)))
	if err == nil || !strings.Contains(err.Error(), "DATABASE_URL is required") {
		t.Fatalf("error = %v, want missing DATABASE_URL", err)
	}
}

func TestLoadFromRejectsUnsafeProductionDatabaseURL(t *testing.T) {
	_, err := LoadFrom(mapLookup(withAuthConfig(map[string]string{
		"APP_ENV":      ProductionEnvironment,
		"DATABASE_URL": "postgres://db.example.test/sitaara?sslmode=disable",
	})))
	if err == nil || !strings.Contains(err.Error(), "must require TLS") {
		t.Fatalf("error = %v, want TLS validation error", err)
	}
}

func TestLoadFromAcceptsProductionTLS(t *testing.T) {
	_, err := LoadFrom(mapLookup(withAuthConfig(map[string]string{
		"APP_ENV":      ProductionEnvironment,
		"DATABASE_URL": "postgres://db.example.test/sitaara?sslmode=verify-full",
	})))
	if err != nil {
		t.Fatalf("LoadFrom returned error: %v", err)
	}
}

func TestLoadFromCollectsInvalidValues(t *testing.T) {
	_, err := LoadFrom(mapLookup(withAuthConfig(map[string]string{
		"APP_ENV":            "staging",
		"PORT":               "70000",
		"DATABASE_URL":       "mysql://localhost/db",
		"LOG_LEVEL":          "verbose",
		"DB_MAX_CONNECTIONS": "0",
	})))
	if err == nil {
		t.Fatal("LoadFrom returned nil error")
	}

	for _, expected := range []string{"APP_ENV", "PORT", "DATABASE_URL", "LOG_LEVEL", "DB_MAX_CONNECTIONS"} {
		if !strings.Contains(err.Error(), expected) {
			t.Errorf("error %q does not contain %q", err, expected)
		}
	}
}

func TestLoadFromRejectsMissingAuthenticationConfiguration(t *testing.T) {
	_, err := LoadFrom(mapLookup(map[string]string{
		"DATABASE_URL": "postgres://127.0.0.1/sitaara?sslmode=disable",
	}))
	if err == nil {
		t.Fatal("LoadFrom returned nil error")
	}

	for _, expected := range []string{"JWT_SECRET", "JWT_ISSUER", "JWT_AUDIENCE", "INVITE_HMAC_SECRET", "REFRESH_HMAC_SECRET"} {
		if !strings.Contains(err.Error(), expected) {
			t.Errorf("error %q does not contain %q", err, expected)
		}
	}
}

func withAuthConfig(values map[string]string) map[string]string {
	result := map[string]string{
		"JWT_SECRET":          strings.Repeat("j", 32),
		"JWT_ISSUER":          "sitaara-api",
		"JWT_AUDIENCE":        "sitaara-mobile",
		"INVITE_HMAC_SECRET":  strings.Repeat("i", 32),
		"REFRESH_HMAC_SECRET": strings.Repeat("r", 32),
	}
	for key, value := range values {
		result[key] = value
	}
	return result
}

func mapLookup(values map[string]string) LookupFunc {
	return func(name string) (string, bool) {
		value, ok := values[name]
		return value, ok
	}
}
