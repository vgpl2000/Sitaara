package httpapi

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/vgpl2000/Sitaara/backend/internal/content"
)

type contentHandler struct {
	logger  *slog.Logger
	service *content.Service
}

type progressRequest struct {
	PositionSeconds int32 `json:"positionSeconds"`
}

func newContentHandler(logger *slog.Logger, service *content.Service) *contentHandler {
	return &contentHandler{logger: logger, service: service}
}

func (h *contentHandler) listMasterclasses(w http.ResponseWriter, r *http.Request) {
	result, err := h.service.ListMasterclasses(r.Context(), principalFromContext(r.Context()).UserID)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, result)
}

func (h *contentHandler) getMasterclass(w http.ResponseWriter, r *http.Request) {
	id, ok := resourceID(w, r, "masterclassId")
	if !ok {
		return
	}
	result, err := h.service.GetMasterclass(r.Context(), principalFromContext(r.Context()).UserID, id)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, result)
}

func (h *contentHandler) getVideo(w http.ResponseWriter, r *http.Request) {
	id, ok := resourceID(w, r, "videoId")
	if !ok {
		return
	}
	result, err := h.service.GetVideo(r.Context(), principalFromContext(r.Context()).UserID, id)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, result)
}

func (h *contentHandler) likeVideo(w http.ResponseWriter, r *http.Request) {
	h.setLiked(w, r, true)
}

func (h *contentHandler) unlikeVideo(w http.ResponseWriter, r *http.Request) {
	h.setLiked(w, r, false)
}

func (h *contentHandler) setLiked(w http.ResponseWriter, r *http.Request, liked bool) {
	id, ok := resourceID(w, r, "videoId")
	if !ok {
		return
	}
	result, err := h.service.SetLiked(r.Context(), principalFromContext(r.Context()).UserID, id, liked)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, map[string]bool{"liked": result})
}

func (h *contentHandler) updateProgress(w http.ResponseWriter, r *http.Request) {
	id, ok := resourceID(w, r, "videoId")
	if !ok {
		return
	}
	var request progressRequest
	if err := decodeJSON(r, &request); err != nil {
		writeDecodeError(w, r, err)
		return
	}
	result, err := h.service.UpdateProgress(r.Context(), principalFromContext(r.Context()).UserID, id, request.PositionSeconds)
	if err != nil {
		h.writeServiceError(w, r, err)
		return
	}
	writeData(w, r, http.StatusOK, result)
}

func (h *contentHandler) writeServiceError(w http.ResponseWriter, r *http.Request, err error) {
	var validationError *content.ValidationError
	switch {
	case errors.As(err, &validationError):
		fields := make(map[string]any, len(validationError.Fields))
		for field, message := range validationError.Fields {
			fields[field] = message
		}
		writeFieldError(w, r, http.StatusBadRequest, "VALIDATION_ERROR", "Check the submitted fields and try again.", fields)
	case errors.Is(err, content.ErrOnboardingNeeded):
		writeError(w, r, http.StatusConflict, "ONBOARDING_REQUIRED", "Create or join a family first.")
	case errors.Is(err, content.ErrContentNotFound):
		writeError(w, r, http.StatusNotFound, "CONTENT_NOT_FOUND", "That content could not be found.")
	default:
		h.logger.ErrorContext(r.Context(), "content operation failed",
			"request_id", requestIDFromContext(r.Context()),
			"error_type", typeName(err),
		)
		writeError(w, r, http.StatusInternalServerError, "INTERNAL_ERROR", "An unexpected error occurred.")
	}
}

func resourceID(w http.ResponseWriter, r *http.Request, parameter string) (uuid.UUID, bool) {
	id, err := uuid.Parse(chi.URLParam(r, parameter))
	if err != nil {
		writeError(w, r, http.StatusNotFound, "CONTENT_NOT_FOUND", "That content could not be found.")
		return uuid.Nil, false
	}
	return id, true
}
