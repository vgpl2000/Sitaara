param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('format', 'lint', 'test', 'test-integration', 'generate', 'migrate-up', 'migrate-status', 'run', 'seed')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
$BackendRoot = Split-Path -Parent $PSScriptRoot
Push-Location $BackendRoot

function Assert-NativeSuccess {
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE."
    }
}

try {
    switch ($Action) {
        'format' {
            go fmt ./...
            Assert-NativeSuccess
        }
        'lint' {
            go vet ./...
            Assert-NativeSuccess
            go run github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.14.0 run
            Assert-NativeSuccess
        }
        'test' {
            go test ./...
            Assert-NativeSuccess
        }
        'test-integration' {
            if (-not $env:TEST_DATABASE_URL) {
                throw 'TEST_DATABASE_URL is required for integration tests.'
            }
            go test -tags=integration ./...
            Assert-NativeSuccess
        }
        'generate' {
            go run github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1 generate
            Assert-NativeSuccess
        }
        'migrate-up' {
            if (-not $env:DATABASE_URL) {
                throw 'DATABASE_URL is required for migrations.'
            }
            go run ./cmd/migrate up
            Assert-NativeSuccess
        }
        'migrate-status' {
            if (-not $env:DATABASE_URL) {
                throw 'DATABASE_URL is required for migrations.'
            }
            go run ./cmd/migrate status
            Assert-NativeSuccess
        }
        'run' {
            go run ./cmd/api
            Assert-NativeSuccess
        }
        'seed' {
            throw 'Content seeding starts in Phase 4; no Phase 1 seed is defined.'
        }
    }
}
finally {
    Pop-Location
}
