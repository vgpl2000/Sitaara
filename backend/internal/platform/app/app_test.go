package app

import (
	"context"
	"errors"
	"sync/atomic"
	"testing"
	"time"
)

func TestRunShutsDownServerAndClosesResources(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	server := &fakeServer{started: make(chan struct{})}
	closer := &fakeCloser{}

	done := make(chan error, 1)
	go func() {
		done <- Run(ctx, server, time.Second, closer)
	}()

	<-server.started
	cancel()

	select {
	case err := <-done:
		if !errors.Is(err, context.Canceled) {
			t.Fatalf("Run error = %v, want context canceled", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("Run did not return")
	}

	if !server.shutdown.Load() {
		t.Fatal("server was not shut down")
	}
	if !closer.closed.Load() {
		t.Fatal("resource was not closed")
	}
}

type fakeServer struct {
	started  chan struct{}
	shutdown atomic.Bool
}

func (s *fakeServer) ListenAndServe() error {
	close(s.started)
	for !s.shutdown.Load() {
		time.Sleep(time.Millisecond)
	}
	return nil
}

func (s *fakeServer) Shutdown(context.Context) error {
	s.shutdown.Store(true)
	return nil
}

type fakeCloser struct {
	closed atomic.Bool
}

func (c *fakeCloser) Close() {
	c.closed.Store(true)
}
