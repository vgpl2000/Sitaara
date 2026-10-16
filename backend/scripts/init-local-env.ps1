param(
    [string]$EnvPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) '.env')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $EnvPath)) {
    throw "Environment file not found: $EnvPath"
}

function New-UrlSafeSecret {
    $bytes = [byte[]]::new(48)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function Test-PlaceholderValue([string]$Value) {
    return [string]::IsNullOrWhiteSpace($Value) -or
        $Value -match '(?i)(replace_with|change[_-]?me|placeholder|example|todo|<.+>)'
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.AddRange([string[]][System.IO.File]::ReadAllLines($EnvPath))
$generated = [System.Collections.Generic.List[string]]::new()

foreach ($name in @('JWT_SECRET', 'INVITE_HMAC_SECRET', 'REFRESH_HMAC_SECRET')) {
    $found = $false
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -notmatch "^$([regex]::Escape($name))=(.*)$") {
            continue
        }

        $found = $true
        if (Test-PlaceholderValue $Matches[1].Trim().Trim('"').Trim("'")) {
            $lines[$index] = "$name=$(New-UrlSafeSecret)"
            $generated.Add($name)
        }
        break
    }

    if (-not $found) {
        $lines.Add("$name=$(New-UrlSafeSecret)")
        $generated.Add($name)
    }
}

for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match '^DATABASE_URL=(.*)$') {
        $databaseURL = $Matches[1]
        if ($databaseURL -match '(?i)sslmode=disable' -and $databaseURL -notmatch '(?i)@(localhost|127\.0\.0\.1|\[::1\])(?=[:/])') {
            $lines[$index] = 'DATABASE_URL=' + ($databaseURL -replace '(?i)sslmode=disable', 'sslmode=require')
        }
    }
}

[System.IO.File]::WriteAllLines($EnvPath, $lines, [System.Text.UTF8Encoding]::new($false))

if ($generated.Count -eq 0) {
    Write-Host 'Authentication secrets already exist; nothing was replaced.'
} else {
    Write-Host ('Generated: ' + ($generated -join ', '))
}
Write-Host 'Remote PostgreSQL URLs are configured to require TLS.'
