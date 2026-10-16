package auth

import (
	"context"
	"strings"
	"testing"
)

func TestPasswordHasherRoundTrip(t *testing.T) {
	hasher := testPasswordHasher()
	encoded, err := hasher.Hash(context.Background(), "correct horse battery staple")
	if err != nil {
		t.Fatalf("Hash returned error: %v", err)
	}
	if strings.Contains(encoded, "correct horse") {
		t.Fatal("encoded hash contains password text")
	}

	matches, err := hasher.Verify(context.Background(), "correct horse battery staple", encoded)
	if err != nil {
		t.Fatalf("Verify returned error: %v", err)
	}
	if !matches {
		t.Fatal("Verify rejected the correct password")
	}

	matches, err = hasher.Verify(context.Background(), "wrong password", encoded)
	if err != nil {
		t.Fatalf("Verify wrong password returned error: %v", err)
	}
	if matches {
		t.Fatal("Verify accepted an incorrect password")
	}
}

func TestPasswordHasherRejectsMalformedEncoding(t *testing.T) {
	_, err := testPasswordHasher().Verify(context.Background(), "password", "$argon2id$broken")
	if err == nil {
		t.Fatal("Verify accepted malformed hash")
	}
}

func testPasswordHasher() *PasswordHasher {
	return NewPasswordHasher(PasswordParams{
		MemoryKiB:   64,
		Iterations:  1,
		Parallelism: 1,
		SaltLength:  16,
		KeyLength:   32,
	}, 1)
}
