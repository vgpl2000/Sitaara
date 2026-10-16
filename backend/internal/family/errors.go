package family

import "errors"

var (
	ErrAlreadyInFamily    = errors.New("user already belongs to a family")
	ErrFamilyRequired     = errors.New("family membership required")
	ErrFamilyAlreadyFull  = errors.New("family already has two members")
	ErrInviteInvalid      = errors.New("invite is invalid")
	ErrInviteExpired      = errors.New("invite has expired")
	ErrInviteAlreadyUsed  = errors.New("invite has already been used")
	ErrSelfLinkNotAllowed = errors.New("self linking is not allowed")
	ErrRoleTaken          = errors.New("family role is already occupied")
)

type ValidationError struct {
	Fields map[string]string
}

func (e *ValidationError) Error() string {
	return "family validation failed"
}
