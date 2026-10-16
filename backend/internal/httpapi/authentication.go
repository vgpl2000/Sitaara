package httpapi

import (
	"context"
	"net/http"
	"strings"

	"github.com/vgpl2000/Sitaara/backend/internal/auth"
)

type principalContextKey struct{}

func authenticationMiddleware(tokens *auth.AccessTokenManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			scheme, rawToken, ok := strings.Cut(r.Header.Get("Authorization"), " ")
			if !ok || !strings.EqualFold(scheme, "Bearer") || rawToken == "" || strings.Contains(rawToken, " ") {
				writeError(w, r, http.StatusUnauthorized, "AUTHENTICATION_REQUIRED", "Please sign in to continue.")
				return
			}

			principal, err := tokens.Validate(rawToken)
			if err != nil {
				writeError(w, r, http.StatusUnauthorized, "INVALID_ACCESS_TOKEN", "Your session is invalid or has expired.")
				return
			}

			ctx := context.WithValue(r.Context(), principalContextKey{}, principal)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func principalFromContext(ctx context.Context) auth.Principal {
	principal, _ := ctx.Value(principalContextKey{}).(auth.Principal)
	return principal
}
