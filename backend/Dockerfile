FROM golang:1.27.0-alpine AS build

ARG VERSION=dev
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w -X main.version=${VERSION}" \
    -o /out/sitaara-api \
    ./cmd/api
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/sitaara-migrate \
    ./cmd/migrate
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/sitaara-seed \
    ./cmd/seed

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app
COPY --from=build /out/sitaara-api /app/sitaara-api
COPY --from=build /out/sitaara-migrate /app/sitaara-migrate
COPY --from=build /out/sitaara-seed /app/sitaara-seed
COPY --from=build /src/migrations /app/migrations
USER nonroot:nonroot
ENTRYPOINT ["/app/sitaara-api"]
