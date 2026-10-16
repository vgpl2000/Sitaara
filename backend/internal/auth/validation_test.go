package auth

import "testing"

func TestNormalizeEmail(t *testing.T) {
	email, err := normalizeEmail("  Parent@Example.COM ")
	if err != nil {
		t.Fatalf("normalizeEmail returned error: %v", err)
	}
	if email != "parent@example.com" {
		t.Fatalf("email = %q", email)
	}
}

func TestValidatePasswordBoundaries(t *testing.T) {
	if err := validatePassword("12345678"); err != nil {
		t.Fatalf("minimum password rejected: %v", err)
	}
	if err := validatePassword("short"); err == nil {
		t.Fatal("short password accepted")
	}
}
