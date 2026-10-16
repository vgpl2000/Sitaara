package httpapi

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/vgpl2000/Sitaara/backend/internal/auth"
	"github.com/vgpl2000/Sitaara/backend/internal/family"
)

type authHandler struct {
	logger  *slog.Logger
	service *auth.Service
	family  *family.Service
}

type credentialsRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type refreshRequest struct {
	RefreshToken string `json:"refreshToken"`
}

func newAuthHandler(logger *slog.Logger, service *auth.Service, familyService *family.Service) *authHandler {
	return &authHandler{logger: logger, service: service, family: familyService}
}

func (h *authHandler) register(w http.ResponseWriter, r *http.Request) {
	var request credentialsRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}

	session, err := h.service.Register(r.Context(), request.Email, request.Password)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusCreated, session)
}

func (h *authHandler) login(w http.ResponseWriter, r *http.Request) {
	var request credentialsRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}

	session, err := h.service.Login(r.Context(), request.Email, request.Password)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, session)
}

func (h *authHandler) refresh(w http.ResponseWriter, r *http.Request) {
	var request refreshRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}

	session, err := h.service.Refresh(r.Context(), request.RefreshToken)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, session)
}

func (h *authHandler) logout(w http.ResponseWriter, r *http.Request) {
	var request refreshRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}

	if err := h.service.Logout(r.Context(), principalFromContext(r.Context()), request.RefreshToken); err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *authHandler) me(w http.ResponseWriter, r *http.Request) {
	current, err := h.service.GetMe(r.Context(), principalFromContext(r.Context()).UserID)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	if h.family != nil {
		familySummary, familyErr := h.family.Get(r.Context(), current.ID)
		switch {
		case familyErr == nil:
			current.OnboardingState = "onboarded"
			current.Family = familySummary
		case errors.Is(familyErr, family.ErrFamilyRequired):
		default:
			h.writeServiceError(w, r, familyErr)
			return
		}
	}
	writeData(w, r, http.StatusOK, current)
}

func (h *authHandler) writeServiceError(w http.ResponseWriter, r *http.Request, err error) {
	var validationError *auth.ValidationError
	switch {
	case errors.As(err, &validationError):
		fields := make(map[string]any, len(validationError.Fields))
		for field, message := range validationError.Fields {
			fields[field] = message
		}
		writeFieldError(w, r, http.StatusBadRequest, "VALIDATION_ERROR", "Check the submitted fields and try again.", fields)
	case errors.Is(err, auth.ErrEmailAlreadyUsed):
		writeError(w, r, http.StatusConflict, "EMAIL_ALREADY_USED", "An account with that email already exists.")
	case errors.Is(err, auth.ErrInvalidCredentials):
		writeError(w, r, http.StatusUnauthorized, "INVALID_CREDENTIALS", "The email or password is incorrect.")
	case errors.Is(err, auth.ErrInvalidRefreshToken):
		writeError(w, r, http.StatusUnauthorized, "INVALID_REFRESH_TOKEN", "The refresh session is invalid or has expired.")
	case errors.Is(err, auth.ErrSessionReused):
		writeError(w, r, http.StatusUnauthorized, "SESSION_REUSED", "This session can no longer be used. Please sign in again.")
	default:
		h.logger.ErrorContext(r.Context(), "authentication operation failed",
			"request_id", requestIDFromContext(r.Context()),
			"error_type", typeName(err),
		)
		writeError(w, r, http.StatusInternalServerError, "INTERNAL_ERROR", "An unexpected error occurred.")
	}
}
