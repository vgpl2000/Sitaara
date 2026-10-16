package auth

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"

	"golang.org/x/crypto/argon2"
)

const argon2Version = 19

type PasswordParams struct {
	MemoryKiB   uint32
	Iterations  uint32
	Parallelism uint8
	SaltLength  uint32
	KeyLength   uint32
}

func DefaultPasswordParams() PasswordParams {
	return PasswordParams{
		MemoryKiB:   64 * 1024,
		Iterations:  3,
		Parallelism: 2,
		SaltLength:  16,
		KeyLength:   32,
	}
}

type PasswordHasher struct {
	params    PasswordParams
	semaphore chan struct{}
}

func NewPasswordHasher(params PasswordParams, maxConcurrency int) *PasswordHasher {
	if maxConcurrency < 1 {
		maxConcurrency = 1
	}
	return &PasswordHasher{params: params, semaphore: make(chan struct{}, maxConcurrency)}
}

func (h *PasswordHasher) Hash(ctx context.Context, password string) (string, error) {
	if err := h.acquire(ctx); err != nil {
		return "", err
	}
	defer h.release()

	salt := make([]byte, h.params.SaltLength)
	if _, err := rand.Read(salt); err != nil {
		return "", fmt.Errorf("generate password salt: %w", err)
	}

	digest := argon2.IDKey(
		[]byte(password),
		salt,
		h.params.Iterations,
		h.params.MemoryKiB,
		h.params.Parallelism,
		h.params.KeyLength,
	)

	return fmt.Sprintf(
		"$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2Version,
		h.params.MemoryKiB,
		h.params.Iterations,
		h.params.Parallelism,
		base64.RawStdEncoding.EncodeToString(salt),
		base64.RawStdEncoding.EncodeToString(digest),
	), nil
}

func (h *PasswordHasher) Verify(ctx context.Context, password, encoded string) (bool, error) {
	params, salt, expected, err := parsePasswordHash(encoded)
	if err != nil {
		return false, err
	}

	if err := h.acquire(ctx); err != nil {
		return false, err
	}
	defer h.release()

	actual := argon2.IDKey(
		[]byte(password),
		salt,
		params.Iterations,
		params.MemoryKiB,
		params.Parallelism,
		uint32(len(expected)),
	)

	return subtle.ConstantTimeCompare(actual, expected) == 1, nil
}

func (h *PasswordHasher) acquire(ctx context.Context) error {
	select {
	case h.semaphore <- struct{}{}:
		return nil
	case <-ctx.Done():
		return fmt.Errorf("wait for password hasher: %w", ctx.Err())
	}
}

func (h *PasswordHasher) release() {
	<-h.semaphore
}

func parsePasswordHash(encoded string) (PasswordParams, []byte, []byte, error) {
	parts := strings.Split(encoded, "$")
	if len(parts) != 6 || parts[1] != "argon2id" {
		return PasswordParams{}, nil, nil, errors.New("invalid password hash format")
	}

	var version int
	if _, err := fmt.Sscanf(parts[2], "v=%d", &version); err != nil || version != argon2Version {
		return PasswordParams{}, nil, nil, errors.New("unsupported password hash version")
	}

	var params PasswordParams
	if _, err := fmt.Sscanf(
		parts[3],
		"m=%d,t=%d,p=%d",
		&params.MemoryKiB,
		&params.Iterations,
		&params.Parallelism,
	); err != nil || params.MemoryKiB < 8 || params.Iterations < 1 || params.Parallelism < 1 {
		return PasswordParams{}, nil, nil, errors.New("invalid password hash parameters")
	}

	salt, err := base64.RawStdEncoding.Strict().DecodeString(parts[4])
	if err != nil || len(salt) < 8 {
		return PasswordParams{}, nil, nil, errors.New("invalid password hash salt")
	}
	digest, err := base64.RawStdEncoding.Strict().DecodeString(parts[5])
	if err != nil || len(digest) < 16 {
		return PasswordParams{}, nil, nil, errors.New("invalid password hash digest")
	}

	params.SaltLength = uint32(len(salt))
	params.KeyLength = uint32(len(digest))
	return params, salt, digest, nil
}
