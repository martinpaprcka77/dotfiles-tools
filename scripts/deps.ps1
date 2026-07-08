<#
.SYNOPSIS
    Installs all dependencies for the PowerShell Dotfiles Ecosystem via winget.
.DESCRIPTION
    Idempotent — skips already-installed packages. Installs: Git, PowerShell 7,
    Windows Terminal, VS Code, oh-my-posh, Cascadia Code Nerd Font,
    PSReadLine, Terminal-Icons, PSFzf, Pester, and more.
.PARAMETER WhatIf
    Pouze zobrazí, co by se nainstalovalo.
.PARAMETER Minimal
    Nainstaluje pouze nezbytné minimum (Git, PowerShell 7, WT).
.EXAMPLE
    .\deps.ps1
    .\deps.ps1 -Minimal
    .\deps.ps1 -WhatIf
.NOTES
    Cesta: ~/Projects/tools/scripts/deps.ps1
    Vyžaduje winget (součást Windows 10 1809+ / Windows 11).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Minimal
)

$ErrorActionPreference = 'Continue'
$script:installed = 0; $script:skipped = 0; $script:failed = 0

function Write-Step { param([string]$M) Write-Host "==> $M" -ForegroundColor Cyan }
function Write-Ok   { param([string]$M) Write-Host "  [+] $M" -ForegroundColor Green;  $script:installed++ }
function Write-Skip { param([string]$M) Write-Host "  [=] $M" -ForegroundColor Gray;   $script:skipped++ }
function Write-Fail { param([string]$M) Write-Host "  [x] $M" -ForegroundColor Red;    $script:failed++ }

function Install-Pkg {
    param([string]$Id, [string]$Name, [string]$ExtraArgs)
    Write-Step "$Name ($Id)..."
    $installed = winget list --id $Id --exact 2>&1 | Select-String $Id
    if ($installed) {
        Write-Skip "Already installed: $Name"
        return
    }
    if ($PSCmdlet.ShouldProcess($Id, "winget install")) {
        $args = @('install', '--id', $Id, '--exact', '--silent', '--accept-source-agreements', '--accept-package-agreements')
        if ($ExtraArgs) { $args += $ExtraArgs.Split(' ') }
        winget @args 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Ok "Installed: $Name" }
        else { Write-Fail "Failed: $Name — try manually: winget install --id $Id" }
    }
}

# ── Core tools (always) ────────────────────────────────────────
Write-Host "`n--- CORE TOOLS ---" -ForegroundColor Magenta
Install-Pkg -Id 'Git.Git'                 -Name 'Git'
Install-Pkg -Id 'Microsoft.PowerShell'    -Name 'PowerShell 7'
Install-Pkg -Id 'Microsoft.WindowsTerminal' -Name 'Windows Terminal'

if ($Minimal) {
    Write-Host "`n=== DEPENDENCIES SUMMARY ===" -ForegroundColor Magenta
    Write-Host "  Installed: $script:installed  Skipped: $script:skipped  Failed: $script:failed"
    return
}

# ── Development tools ──────────────────────────────────────────
Write-Host "`n--- DEVELOPMENT ---" -ForegroundColor Magenta
Install-Pkg -Id 'Microsoft.VisualStudioCode' -Name 'VS Code'

# ── Shell enhancement ──────────────────────────────────────────
Write-Host "`n--- SHELL ENHANCEMENT ---" -ForegroundColor Magenta
Install-Pkg -Id 'JanDeDobbeleer.OhMyPosh' -Name 'oh-my-posh'

# ── Fonts ──────────────────────────────────────────────────────
Write-Host "`n--- FONTS ---" -ForegroundColor Magenta
# Cascadia Code Nerd Font — needed for oh-my-posh glyphs
$fontInstalled = winget list --id 'DEVCOM.JetBrainsMonoNerdFont' --exact 2>&1 | Select-String 'JetBrains'
if ($fontInstalled) {
    Write-Skip "Nerd Font already installed"
} else {
    Write-Step "Cascadia Code Nerd Font — install manually:"
    Write-Host "  https://github.com/ryanoasis/nerd-fonts/releases" -ForegroundColor Yellow
    Write-Host "  Download CascadiaCode.zip, extract, select all .ttf, right-click → Install" -ForegroundColor Yellow
}

# ── PowerShell modules ─────────────────────────────────────────
Write-Host "`n--- POWERSHELL MODULES ---" -ForegroundColor Magenta
$modules = @(
    @{ Name = 'PSReadLine';        MinVersion = '2.3.6' },
    @{ Name = 'Terminal-Icons';    MinVersion = '0.11.0' },
    @{ Name = 'PSFzf';             MinVersion = '2.5.0' },
    @{ Name = 'Pester';            MinVersion = '5.7.0' }
)

pwsh -NoProfile -Command {
    param($mods)
    foreach ($m in $mods) {
        $existing = Get-Module -ListAvailable -Name $m.Name | Sort-Object Version -Descending | Select-Object -First 1
        if ($existing -and $existing.Version -ge [version]$m.MinVersion) {
            Write-Host "  [=] Already installed: $($m.Name) v$($existing.Version)" -ForegroundColor Gray
        } else {
            Write-Host "  ==> Installing: $($m.Name)..." -ForegroundColor Cyan
            Install-PSResource -Name $m.Name -TrustRepository -ErrorAction SilentlyContinue
            if ($?) { Write-Host "  [+] Installed: $($m.Name)" -ForegroundColor Green }
            else { Write-Host "  [x] Failed: $($m.Name)" -ForegroundColor Red }
        }
    }
} -args $modules

# ── Summary ────────────────────────────────────────────────────
Write-Host "`n=== DEPENDENCIES SUMMARY ===" -ForegroundColor Magenta
Write-Host "  Installed: $script:installed  Skipped: $script:skipped  Failed: $script:failed"
if ($script:failed -gt 0) {
    Write-Host "  Some items failed. Re-run or install manually." -ForegroundColor Yellow
}
Write-Host "`nNext: run ~/.config/powershell/install.ps1 to set up profiles." -ForegroundColor Cyan
