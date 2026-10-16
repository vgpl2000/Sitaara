package family

import (
	"testing"
	"time"
)

func TestValidateChildAgeBoundaries(t *testing.T) {
	now := time.Date(2026, time.October, 16, 12, 0, 0, 0, time.UTC)

	if _, _, err := validateChild(" Aarav ", "2024-04-12", now); err != nil {
		t.Fatalf("valid child rejected: %v", err)
	}
	if _, _, err := validateChild("Aarav", "2020-10-16", now); err == nil {
		t.Fatal("exactly six-year-old child accepted")
	}
	if _, _, err := validateChild("Aarav", "2026-10-17", now); err == nil {
		t.Fatal("future date accepted")
	}
}

func TestInviteCodeGenerationAndNormalization(t *testing.T) {
	code, err := newInviteCode()
	if err != nil {
		t.Fatalf("newInviteCode returned error: %v", err)
	}
	if len(code) != 6 {
		t.Fatalf("code length = %d", len(code))
	}
	normalized, valid := normalizeInviteCode(code[:3] + "-" + code[3:])
	if !valid || normalized != code {
		t.Fatalf("normalized = %q, valid = %v", normalized, valid)
	}
	if _, valid := normalizeInviteCode("IO01XX"); valid {
		t.Fatal("ambiguous invite alphabet accepted")
	}
}

func TestInviteDigestIsKeyed(t *testing.T) {
	first := digestInviteCode([]byte("first-key"), "ABCDEFG")
	second := digestInviteCode([]byte("second-key"), "ABCDEFG")
	if first == second {
		t.Fatal("invite digest does not depend on its key")
	}
}
