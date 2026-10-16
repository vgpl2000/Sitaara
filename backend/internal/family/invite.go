package family

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"strings"
)

const inviteAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

func newInviteCode() (string, error) {
	random := make([]byte, 6)
	if _, err := rand.Read(random); err != nil {
		return "", err
	}
	code := make([]byte, len(random))
	for index, value := range random {
		code[index] = inviteAlphabet[int(value)&31]
	}
	return string(code), nil
}

func normalizeInviteCode(raw string) (string, bool) {
	normalized := strings.ToUpper(strings.NewReplacer("-", "", " ", "").Replace(strings.TrimSpace(raw)))
	if len(normalized) != 6 {
		return "", false
	}
	for _, character := range normalized {
		if !strings.ContainsRune(inviteAlphabet, character) {
			return "", false
		}
	}
	return normalized, true
}

func digestInviteCode(secret []byte, code string) string {
	digest := hmac.New(sha256.New, secret)
	_, _ = digest.Write([]byte(code))
	return hex.EncodeToString(digest.Sum(nil))
}
