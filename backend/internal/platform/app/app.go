package app

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"
)

type HTTPServer interface {
	ListenAndServe() error
	Shutdown(context.Context) error
}

type Closer interface {
	Close()
}

func Run(ctx context.Context, server HTTPServer, shutdownTimeout time.Duration, closers ...Closer) error {
	defer func() {
		for i := len(closers) - 1; i >= 0; i-- {
			closers[i].Close()
		}
	}()

	serverErrors := make(chan error, 1)
	go func() {
		serverErrors <- server.ListenAndServe()
	}()

	select {
	case err := <-serverErrors:
		if err == nil || errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return fmt.Errorf("listen: %w", err)
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
		defer cancel()
		if err := server.Shutdown(shutdownCtx); err != nil {
			return fmt.Errorf("shutdown: %w", err)
		}
		return ctx.Err()
	}
}
