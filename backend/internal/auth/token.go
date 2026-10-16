package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type Clock func() time.Time

type Principal struct {
	UserID        uuid.UUID
	SessionFamily uuid.UUID
}

type AccessTokenManager struct {
	secret   []byte
	issuer   string
	audience string
	ttl      time.Duration
	leeway   time.Duration
	now      Clock
}

type accessClaims struct {
	SessionFamily string `json:"sid"`
	jwt.RegisteredClaims
}

func NewAccessTokenManager(secret []byte, issuer, audience string, ttl time.Duration, now Clock) *AccessTokenManager {
	return &AccessTokenManager{
		secret:   append([]byte(nil), secret...),
		issuer:   issuer,
		audience: audience,
		ttl:      ttl,
		leeway:   30 * time.Second,
		now:      now,
	}
}

func (m *AccessTokenManager) Issue(userID, familyID uuid.UUID) (string, time.Time, error) {
	now := m.now().UTC()
	expiresAt := now.Add(m.ttl)
	claims := accessClaims{
		SessionFamily: familyID.String(),
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    m.issuer,
			Subject:   userID.String(),
			Audience:  jwt.ClaimStrings{m.audience},
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(now),
			ID:        uuid.NewString(),
		},
	}

	signed, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(m.secret)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("sign access token: %w", err)
	}
	return signed, expiresAt, nil
}

func (m *AccessTokenManager) Validate(raw string) (Principal, error) {
	claims := &accessClaims{}
	token, err := jwt.ParseWithClaims(
		raw,
		claims,
		func(token *jwt.Token) (any, error) {
			if token.Method != jwt.SigningMethodHS256 {
				return nil, ErrInvalidAccessToken
			}
			return m.secret, nil
		},
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}),
		jwt.WithIssuer(m.issuer),
		jwt.WithAudience(m.audience),
		jwt.WithExpirationRequired(),
		jwt.WithIssuedAt(),
		jwt.WithLeeway(m.leeway),
		jwt.WithTimeFunc(m.now),
	)
	if err != nil || !token.Valid || claims.ID == "" || claims.IssuedAt == nil {
		return Principal{}, ErrInvalidAccessToken
	}

	userID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return Principal{}, ErrInvalidAccessToken
	}
	familyID, err := uuid.Parse(claims.SessionFamily)
	if err != nil {
		return Principal{}, ErrInvalidAccessToken
	}

	return Principal{UserID: userID, SessionFamily: familyID}, nil
}

func newOpaqueToken() (string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", fmt.Errorf("generate refresh token: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(bytes), nil
}

func digestOpaqueToken(secret []byte, raw string) string {
	digest := hmac.New(sha256.New, secret)
	_, _ = digest.Write([]byte(raw))
	return hex.EncodeToString(digest.Sum(nil))
}
