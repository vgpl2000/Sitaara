package family

import (
	"strings"
	"time"
	"unicode/utf8"

	postgresgen "github.com/vgpl2000/Sitaara/backend/internal/postgres/gen"
)

func parseRole(raw string) (postgresgen.ParentRole, error) {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case string(postgresgen.ParentRoleMom):
		return postgresgen.ParentRoleMom, nil
	case string(postgresgen.ParentRoleDad):
		return postgresgen.ParentRoleDad, nil
	default:
		return "", &ValidationError{Fields: map[string]string{"role": "Choose either mom or dad."}}
	}
}

func validateChild(name, rawDate string, now time.Time) (string, time.Time, error) {
	trimmedName := strings.TrimSpace(name)
	nameLength := utf8.RuneCountInString(trimmedName)
	fields := map[string]string{}
	if nameLength < 1 || nameLength > 80 || !utf8.ValidString(trimmedName) {
		fields["child.name"] = "Enter a child name between 1 and 80 characters."
	}

	dateOfBirth, err := time.Parse("2006-01-02", rawDate)
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	if err != nil {
		fields["child.dateOfBirth"] = "Enter a valid date of birth."
	} else if dateOfBirth.After(today) || !dateOfBirth.After(today.AddDate(-6, 0, 0)) {
		fields["child.dateOfBirth"] = "The child must be between 0 and 5 years old."
	}

	if len(fields) > 0 {
		return "", time.Time{}, &ValidationError{Fields: fields}
	}
	return trimmedName, dateOfBirth, nil
}
