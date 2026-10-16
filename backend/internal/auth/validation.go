package auth

import (
	"net/mail"
	"strings"
	"unicode/utf8"
)

func normalizeEmail(raw string) (string, error) {
	normalized := strings.ToLower(strings.TrimSpace(raw))
	if normalized == "" || len(normalized) > 254 {
		return "", &ValidationError{Fields: map[string]string{"email": "Enter a valid email address."}}
	}
	parsed, err := mail.ParseAddress(normalized)
	if err != nil || parsed.Address != normalized || !strings.Contains(normalized, "@") {
		return "", &ValidationError{Fields: map[string]string{"email": "Enter a valid email address."}}
	}
	return normalized, nil
}

func validatePassword(password string) error {
	byteLength := len([]byte(password))
	if byteLength < 8 || byteLength > 128 || !utf8.ValidString(password) {
		return &ValidationError{Fields: map[string]string{
			"password": "Use a password between 8 and 128 bytes.",
		}}
	}
	return nil
}
