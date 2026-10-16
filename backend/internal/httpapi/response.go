package httpapi

import (
	"encoding/json"
	"net/http"
)

type responseEnvelope struct {
	Data  any              `json:"data,omitempty"`
	Error *responseError   `json:"error,omitempty"`
	Meta  responseMetadata `json:"meta"`
}

type responseError struct {
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Fields  map[string]any `json:"fields"`
}

type responseMetadata struct {
	RequestID string `json:"requestId"`
}

func writeData(w http.ResponseWriter, r *http.Request, status int, data any) {
	writeJSON(w, status, responseEnvelope{
		Data: data,
		Meta: responseMetadata{RequestID: requestIDFromContext(r.Context())},
	})
}

func writeError(w http.ResponseWriter, r *http.Request, status int, code, message string) {
	writeFieldError(w, r, status, code, message, map[string]any{})
}

func writeFieldError(w http.ResponseWriter, r *http.Request, status int, code, message string, fields map[string]any) {
	writeJSON(w, status, responseEnvelope{
		Error: &responseError{
			Code:    code,
			Message: message,
			Fields:  fields,
		},
		Meta: responseMetadata{RequestID: requestIDFromContext(r.Context())},
	})
}

func writeJSON(w http.ResponseWriter, status int, payload responseEnvelope) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
