package auth

import (
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func TestAccessTokenIssueAndValidate(t *testing.T) {
	now := time.Date(2026, time.October, 16, 12, 0, 0, 0, time.UTC)
	manager := NewAccessTokenManager([]byte(strings.Repeat("s", 32)), "issuer", "audience", 15*time.Minute, func() time.Time { return now })
	userID := uuid.New()
	familyID := uuid.New()

	raw, expiresAt, err := manager.Issue(userID, familyID)
	if err != nil {
		t.Fatalf("Issue returned error: %v", err)
	}
	if !expiresAt.Equal(now.Add(15 * time.Minute)) {
		t.Fatalf("expiry = %v", expiresAt)
	}

	principal, err := manager.Validate(raw)
	if err != nil {
		t.Fatalf("Validate returned error: %v", err)
	}
	if principal.UserID != userID || principal.SessionFamily != familyID {
		t.Fatalf("principal = %#v", principal)
	}
}

func TestAccessTokenRejectsExpiryIssuerAndAlgorithm(t *testing.T) {
	issuedAt := time.Date(2026, time.October, 16, 12, 0, 0, 0, time.UTC)
	now := issuedAt
	secret := []byte(strings.Repeat("s", 32))
	manager := NewAccessTokenManager(secret, "issuer", "audience", time.Minute, func() time.Time { return now })
	raw, _, err := manager.Issue(uuid.New(), uuid.New())
	if err != nil {
		t.Fatalf("Issue returned error: %v", err)
	}

	now = issuedAt.Add(2 * time.Minute)
	if _, err := manager.Validate(raw); !errors.Is(err, ErrInvalidAccessToken) {
		t.Fatalf("expired token error = %v", err)
	}

	now = issuedAt
	wrongIssuer := NewAccessTokenManager(secret, "other-issuer", "audience", time.Minute, func() time.Time { return now })
	if _, err := wrongIssuer.Validate(raw); !errors.Is(err, ErrInvalidAccessToken) {
		t.Fatalf("wrong issuer error = %v", err)
	}

	claims := accessClaims{
		SessionFamily: uuid.NewString(),
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    "issuer",
			Subject:   uuid.NewString(),
			Audience:  jwt.ClaimStrings{"audience"},
			ExpiresAt: jwt.NewNumericDate(now.Add(time.Minute)),
			IssuedAt:  jwt.NewNumericDate(now),
			ID:        uuid.NewString(),
		},
	}
	wrongAlgorithm, err := jwt.NewWithClaims(jwt.SigningMethodHS384, claims).SignedString(secret)
	if err != nil {
		t.Fatalf("sign wrong algorithm token: %v", err)
	}
	if _, err := manager.Validate(wrongAlgorithm); !errors.Is(err, ErrInvalidAccessToken) {
		t.Fatalf("wrong algorithm error = %v", err)
	}
}

func TestOpaqueTokenDigestIsKeyedAndStable(t *testing.T) {
	raw, err := newOpaqueToken()
	if err != nil {
		t.Fatalf("newOpaqueToken returned error: %v", err)
	}
	if len(raw) < 43 {
		t.Fatalf("token length = %d", len(raw))
	}

	first := digestOpaqueToken([]byte("first-key"), raw)
	if first != digestOpaqueToken([]byte("first-key"), raw) {
		t.Fatal("digest is not stable")
	}
	if first == digestOpaqueToken([]byte("second-key"), raw) {
		t.Fatal("digest does not depend on its key")
	}
	if strings.Contains(first, raw) {
		t.Fatal("digest contains raw token")
	}
}
