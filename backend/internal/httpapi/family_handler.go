package httpapi

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/vgpl2000/Sitaara/backend/internal/family"
)

type familyHandler struct {
	logger  *slog.Logger
	service *family.Service
}

type createFamilyRequest struct {
	Role  string `json:"role"`
	Child struct {
		Name        string `json:"name"`
		DateOfBirth string `json:"dateOfBirth"`
	} `json:"child"`
}

type redeemInviteRequest struct {
	Code string `json:"code"`
	Role string `json:"role"`
}

func newFamilyHandler(logger *slog.Logger, service *family.Service) *familyHandler {
	return &familyHandler{logger: logger, service: service}
}

func (h *familyHandler) create(w http.ResponseWriter, r *http.Request) {
	var request createFamilyRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}
	principal := principalFromContext(r.Context())
	created, err := h.service.Create(r.Context(), principal.UserID, request.Role, request.Child.Name, request.Child.DateOfBirth)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusCreated, created)
}

func (h *familyHandler) get(w http.ResponseWriter, r *http.Request) {
	result, err := h.service.Get(r.Context(), principalFromContext(r.Context()).UserID)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, result)
}

func (h *familyHandler) createInvite(w http.ResponseWriter, r *http.Request) {
	result, err := h.service.CreateInvite(r.Context(), principalFromContext(r.Context()).UserID)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusCreated, result)
}

func (h *familyHandler) redeemInvite(w http.ResponseWriter, r *http.Request) {
	var request redeemInviteRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}
	result, err := h.service.RedeemInvite(r.Context(), principalFromContext(r.Context()).UserID, request.Code, request.Role)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, result)
}

func (h *familyHandler) writeServiceError(w http.ResponseWriter, r *http.Request, err error) {
	var validationError *family.ValidationError
	switch {
	case errors.As(err, &validationError):
		fields := make(map[string]any, len(validationError.Fields))
		for field, message := range validationError.Fields {
			fields[field] = message
		}
		writeFieldError(w, r, http.StatusBadRequest, "VALIDATION_ERROR", "Check the submitted fields and try again.", fields)
	case errors.Is(err, family.ErrAlreadyInFamily):
		writeError(w, r, http.StatusConflict, "ALREADY_IN_FAMILY", "This account already belongs to a family.")
	case errors.Is(err, family.ErrFamilyRequired):
		writeError(w, r, http.StatusConflict, "FAMILY_REQUIRED", "Create or join a family first.")
	case errors.Is(err, family.ErrFamilyAlreadyFull):
		writeError(w, r, http.StatusConflict, "FAMILY_ALREADY_FULL", "This family already has two parents.")
	case errors.Is(err, family.ErrInviteInvalid):
		writeError(w, r, http.StatusBadRequest, "INVITE_INVALID", "That invite code is invalid.")
	case errors.Is(err, family.ErrInviteExpired):
		writeError(w, r, http.StatusConflict, "INVITE_EXPIRED", "That invite code has expired.")
	case errors.Is(err, family.ErrInviteAlreadyUsed):
		writeError(w, r, http.StatusConflict, "INVITE_ALREADY_USED", "That invite code has already been used.")
	case errors.Is(err, family.ErrSelfLinkNotAllowed):
		writeError(w, r, http.StatusConflict, "SELF_LINK_NOT_ALLOWED", "You cannot join your own family invite.")
	case errors.Is(err, family.ErrRoleTaken):
		writeError(w, r, http.StatusConflict, "ROLE_TAKEN", "That parent role is already occupied.")
	default:
		h.logger.ErrorContext(r.Context(), "family operation failed",
			"request_id", requestIDFromContext(r.Context()),
			"error_type", typeName(err),
		)
		writeError(w, r, http.StatusInternalServerError, "INTERNAL_ERROR", "An unexpected error occurred.")
	}
}
