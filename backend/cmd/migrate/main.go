package main

import (
	"database/sql"
	"errors"
	"fmt"
	"os"

	"github.com/pressly/goose/v3"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(arguments []string) (resultErr error) {
	if len(arguments) != 1 {
		return fmt.Errorf("usage: go run ./cmd/migrate <up|status|down-one>")
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return fmt.Errorf("DATABASE_URL is required")
	}

	database, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return fmt.Errorf("open database: %w", err)
	}
	defer func() {
		if err := database.Close(); err != nil {
			resultErr = errors.Join(resultErr, fmt.Errorf("close database: %w", err))
		}
	}()

	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("set migration dialect: %w", err)
	}

	switch arguments[0] {
	case "up":
		err = goose.Up(database, "migrations")
	case "status":
		err = goose.Status(database, "migrations")
	case "down-one":
		err = goose.Down(database, "migrations")
	default:
		return fmt.Errorf("unknown migration command %q", arguments[0])
	}
	if err != nil {
		return fmt.Errorf("migration %s: %w", arguments[0], err)
	}

	return nil
}
