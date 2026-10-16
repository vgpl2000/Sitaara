package auth

import "errors"

var (
	ErrEmailAlreadyUsed    = errors.New("email already used")
	ErrInvalidCredentials  = errors.New("invalid credentials")
	ErrInvalidRefreshToken = errors.New("invalid refresh token")
	ErrSessionReused       = errors.New("refresh session reused")
	ErrInvalidAccessToken  = errors.New("invalid access token")
)

type ValidationError struct {
	Fields map[string]string
}

func (e *ValidationError) Error() string {
	return "validation failed"
}
