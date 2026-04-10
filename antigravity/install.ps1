<#
.SYNOPSIS
    Antigravity Windows config linker - symlinks settings.json and
    keybindings.json from dotfiles into %APPDATA%\Antigravity\User\.

.DESCRIPTION
    Run from PowerShell:  .\antigravity\install.ps1
    Self-elevates to Administrator (required to create symlinks without
    Developer Mode). Does NOT install Antigravity - assumes it is already
    installed on Windows. Existing real files are backed up to
    <file>.backup.<timestamp>.
#>

$ErrorActionPreference = 'Stop'

trap {
    Write-Host ""
    Write-Host "[ERR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    Read-Host 'Press Enter to close'
    exit 1
}

# --- Self-elevate to Administrator -------------------------------------------
$currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[INFO] Elevating to Administrator..." -ForegroundColor Cyan
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$scriptPath`""
    )
    exit
}

function Write-Header($msg) { Write-Host "`n== $msg ==`n" -ForegroundColor Magenta }
function Write-Info($msg)   { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)     { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg)   { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg)    { Write-Host "[ERR]  $msg" -ForegroundColor Red }

Write-Header 'Antigravity'

# --- Resolve paths -----------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = $ScriptDir
$TargetDir = Join-Path $env:APPDATA 'Antigravity\User'

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Write-Ok "Created $TargetDir"
}

$links = @(
    @{ Source = Join-Path $SourceDir 'settings.json';    Target = Join-Path $TargetDir 'settings.json'    }
    @{ Source = Join-Path $SourceDir 'keybindings.json'; Target = Join-Path $TargetDir 'keybindings.json' }
)

foreach ($link in $links) {
    $src = $link.Source
    $dst = $link.Target

    if (-not (Test-Path $src)) {
        Write-Warn "Source missing, skipping: $src"
        continue
    }

    $existing = Get-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType -eq 'SymbolicLink' -and $existing.Target -contains $src) {
            Write-Ok "$dst -> $src (already linked)"
            continue
        }
        $stamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backup = "$dst.backup.$stamp"
        Move-Item -LiteralPath $dst -Destination $backup -Force
        Write-Warn "Backed up existing $dst -> $backup"
    }

    New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
    Write-Ok "$dst -> $src"
}

# --- Install extensions ------------------------------------------------------
Write-Header 'Extensions'

$extensionsFile = Join-Path $SourceDir 'extensions.txt'
$antigravityCmd = Get-Command 'antigravity' -ErrorAction SilentlyContinue
if (-not $antigravityCmd) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Programs\Antigravity\bin\antigravity.cmd'
    if (Test-Path $fallback) { $antigravityCmd = @{ Source = $fallback } }
}

if (-not (Test-Path $extensionsFile)) {
    Write-Warn "extensions.txt not found, skipping"
} elseif (-not $antigravityCmd) {
    Write-Warn "Antigravity CLI not found on PATH, skipping extension install"
} else {
    $cli = $antigravityCmd.Source
    Write-Info "Using CLI: $cli"
    Get-Content $extensionsFile | ForEach-Object {
        $ext = $_.Trim()
        if (-not $ext -or $ext.StartsWith('#')) { return }
        Write-Info "Installing $ext"
        # Redirect stderr to stdout so the noisy analytics warning doesn't abort
        # the script under $ErrorActionPreference = 'Stop'.
        $output = & cmd.exe /c "`"$cli`" --install-extension `"$ext`" --force 2>&1"
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Installed $ext"
        } else {
            Write-Warn "Failed ($LASTEXITCODE): $ext`n$output"
        }
    }
}

Write-Header 'Done'
Write-Info 'Restart Antigravity to pick up the new settings.'
Write-Host ''
Read-Host 'Press Enter to close'
