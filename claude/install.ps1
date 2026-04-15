<#
.SYNOPSIS
    Claude Code Windows installer - installs prerequisites via winget and
    symlinks dotfiles settings.json + CLAUDE.md into %USERPROFILE%\.claude\.

.DESCRIPTION
    Run from PowerShell:  .\claude\install.ps1
    Self-elevates to Administrator (required to create symlinks without
    Developer Mode). Safe to re-run; existing real files are backed up to
    <file>.backup.<timestamp>, existing correct symlinks are left alone.

.NOTES
    Prerequisites installed via winget:
      - Anthropic.ClaudeCode
      - OpenJS.NodeJS.LTS   (needed for statusline: @owloops/claude-powerline)
      - Git.Git             (Claude Code uses Git Bash internally)
      - GitHub.cli          (some plugins / skills shell out to `gh`)
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

# --- Resolve dotfiles root (parent of this script's directory) ---------------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesDir = Split-Path -Parent $ScriptDir
$SourceDir   = Join-Path $DotfilesDir '.claude'

if (-not (Test-Path $SourceDir)) {
    Write-Err "Source directory not found: $SourceDir"
    exit 1
}

# --- Install prerequisites via winget ----------------------------------------
Write-Header 'Installing prerequisites (winget)'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Err 'winget not found. Install App Installer from the Microsoft Store and re-run.'
    exit 1
}

$packages = @(
    @{ Id = 'Anthropic.ClaudeCode';  Name = 'Claude Code' }
    @{ Id = 'OpenJS.NodeJS.LTS';     Name = 'Node.js LTS'  }
    @{ Id = 'Git.Git';               Name = 'Git for Windows' }
    @{ Id = 'GitHub.cli';            Name = 'GitHub CLI' }
)

foreach ($pkg in $packages) {
    Write-Info "Checking $($pkg.Name) ($($pkg.Id))..."
    $installed = winget list --id $pkg.Id --exact 2>$null | Select-String -Pattern $pkg.Id -Quiet
    if ($installed) {
        Write-Ok "$($pkg.Name) already installed"
    } else {
        Write-Info "Installing $($pkg.Name)..."
        winget install --id $pkg.Id --exact --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "winget install $($pkg.Id) returned $LASTEXITCODE - continuing"
        } else {
            Write-Ok "$($pkg.Name) installed"
        }
    }
}

# --- Symlink config files ----------------------------------------------------
Write-Header 'Linking Claude Code config'

$targetDir = Join-Path $env:USERPROFILE '.claude'
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Ok "Created $targetDir"
}

$links = @(
    @{ Source = Join-Path $SourceDir 'settings.json';          Target = Join-Path $targetDir 'settings.json'          }
    @{ Source = Join-Path $SourceDir 'CLAUDE.md';              Target = Join-Path $targetDir 'CLAUDE.md'              }
    @{ Source = Join-Path $SourceDir 'claude-powerline.json';  Target = Join-Path $targetDir 'claude-powerline.json'  }
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

# --- Install claude-powerline globally --------------------------------------
Write-Header 'Installing claude-powerline (npm global)'

if (Get-Command npm -ErrorAction SilentlyContinue) {
    $plInstalled = npm list -g --depth=0 2>$null | Select-String -Pattern '@owloops/claude-powerline' -Quiet
    if ($plInstalled) {
        Write-Ok '@owloops/claude-powerline already installed'
    } else {
        Write-Info 'Installing @owloops/claude-powerline globally...'
        npm install -g '@owloops/claude-powerline'
        if ($LASTEXITCODE -eq 0) {
            Write-Ok '@owloops/claude-powerline installed'
        } else {
            Write-Warn "npm install returned $LASTEXITCODE - statusline may not work until resolved"
        }
    }
} else {
    Write-Warn 'npm not found on PATH yet. Restart terminal and run: npm install -g @owloops/claude-powerline'
}

Write-Header 'Done'
Write-Info 'Restart your terminal so PATH updates from winget take effect.'
Write-Info 'Then run: claude'
Write-Host ''
Read-Host 'Press Enter to close'
