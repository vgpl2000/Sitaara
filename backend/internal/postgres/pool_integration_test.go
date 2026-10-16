//go:build integration

package postgres

import (
	"context"
	"os"
	"testing"
	"time"
)

func TestOpenConnectsToPostgres(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("TEST_DATABASE_URL is not set")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := Open(ctx, databaseURL, PoolOptions{
		MaxConnections: 2,
		ConnectTimeout: 5 * time.Second,
	})
	if err != nil {
		t.Fatalf("Open returned error: %v", err)
	}
	defer pool.Close()

	var value int
	if err := pool.QueryRow(ctx, "select 1").Scan(&value); err != nil {
		t.Fatalf("query failed: %v", err)
	}
	if value != 1 {
		t.Fatalf("query value = %d, want 1", value)
	}
}
