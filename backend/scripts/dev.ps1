param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('format', 'lint', 'test', 'test-integration', 'generate', 'migrate-up', 'migrate-status', 'run', 'seed')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
$BackendRoot = Split-Path -Parent $PSScriptRoot
$RepositoryRoot = Split-Path -Parent $BackendRoot
$RootEnvPath = Join-Path $RepositoryRoot '.env'

function Import-DotEnv([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith('#')) {
            continue
        }

        $separator = $trimmed.IndexOf('=')
        if ($separator -lt 1) {
            continue
        }

        $name = $trimmed.Substring(0, $separator).Trim()
        $value = $trimmed.Substring($separator + 1).Trim()
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        if ([Environment]::GetEnvironmentVariable($name, 'Process') -eq $null) {
            [Environment]::SetEnvironmentVariable($name, $value, 'Process')
        }
    }
}

Import-DotEnv $RootEnvPath
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
            if (-not $env:DATABASE_URL) {
                throw 'DATABASE_URL is required for content seeding.'
            }
            if (-not $env:CLOUDINARY_CLOUD_NAME) {
                throw 'CLOUDINARY_CLOUD_NAME is required for content seeding.'
            }
            go run ./cmd/seed
            Assert-NativeSuccess
        }
    }
}
finally {
    Pop-Location
}
