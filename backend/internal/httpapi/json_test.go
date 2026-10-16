package httpapi

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestDecodeJSONRejectsUnknownFieldsAndMultipleObjects(t *testing.T) {
	for name, body := range map[string]string{
		"unknown field":    `{"name":"value","unexpected":true}`,
		"multiple objects": `{"name":"first"}{"name":"second"}`,
	} {
		t.Run(name, func(t *testing.T) {
			request := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(body))
			var destination struct {
				Name string `json:"name"`
			}
			if err := decodeJSON(request, &destination); err == nil {
				t.Fatal("decodeJSON accepted invalid request")
			}
		})
	}
}

func TestDecodeJSONReportsOversizedBody(t *testing.T) {
	request := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(`{"name":"too large"}`))
	response := httptest.NewRecorder()
	request.Body = http.MaxBytesReader(response, request.Body, 4)

	var destination map[string]any
	err := decodeJSON(request, &destination)
	if err == nil {
		t.Fatal("decodeJSON accepted oversized request")
	}
	writeDecodeError(response, request, err)
	if response.Code != http.StatusRequestEntityTooLarge {
		t.Fatalf("status = %d, want 413", response.Code)
	}
}
