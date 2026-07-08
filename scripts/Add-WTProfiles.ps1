<#
.SYNOPSIS
    Generates a Windows Terminal JSON fragment extension (2026 recommended approach).
.DESCRIPTION
    Creates a fragment at %LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dotfiles\
    instead of editing settings.json directly. This is Microsoft's recommended method
    since WT 1.24+. Safe, no comment-stripping needed, supports updates.
.PARAMETER WhatIf
    Pouze zobrazí, co by se provedlo, beze změn.
.PARAMETER Force
    Přepíše existující fragment.
.EXAMPLE
    .\Add-WTProfiles.ps1
    .\Add-WTProfiles.ps1 -WhatIf
    .\Add-WTProfiles.ps1 -Force
.NOTES
    Fragment location: %LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json
    Uses "updates" key to modify built-in PowerShell profiles.
    Cesta: ~/Projects/tools/scripts/Add-WTProfiles.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Force
)

# Cross-platform guard
if ($IsLinux -or $IsMacOS) {
    Write-Error "Add-WTProfiles.ps1 requires Windows. This is a Linux/macOS system."
    exit 1
}

$ErrorActionPreference = 'Stop'

$fragmentDir = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles"
$fragmentPath = Join-Path $fragmentDir 'dotfiles.json'
$toolsRoot = Join-Path $HOME 'Projects\tools'
$iconsDir = Join-Path $toolsRoot 'icons'

function Write-Step { param([string]$M) Write-Host "==> $M" -ForegroundColor Cyan }
function Write-Ok   { param([string]$M) Write-Host "  [+] $M" -ForegroundColor Green }
function Write-Skip { param([string]$M) Write-Host "  [=] $M" -ForegroundColor Gray }

# ── Check if already installed ─────────────────────────────────
if (Test-Path $fragmentPath -and -not $Force) {
    Write-Skip "Fragment already exists at: $fragmentPath"
    Write-Skip "Use -Force to overwrite."
    exit 0
}

# ── Determine icon paths (relative to fragment for WT 1.24+) ──
# WT 1.24+ resolves icons relative to fragment directory. For absolute paths,
# we still use full paths since we're generating from tools/scripts.
$icons = @{
    menu     = if (Test-Path (Join-Path $iconsDir 'menu.png'))     { Join-Path $iconsDir 'menu.png' }     else { $null }
    projects = if (Test-Path (Join-Path $iconsDir 'projects.png')) { Join-Path $iconsDir 'projects.png' } else { $null }
    pwsh7    = if (Test-Path (Join-Path $iconsDir 'pwsh7.png'))    { Join-Path $iconsDir 'pwsh7.png' }    else { $null }
    pwsh5    = if (Test-Path (Join-Path $iconsDir 'pwsh5.png'))    { Join-Path $iconsDir 'pwsh5.png' }    else { $null }
}

# ── Build fragment JSON ────────────────────────────────────────
$fragment = @{
    '$schema' = 'https://aka.ms/terminal-profiles-schema'
    profiles  = @(
        # ── Custom profile: Menu ──
        @{
            name         = 'Menu'
            commandline  = "pwsh.exe -NoExit -Command `"& '$toolsRoot\menu\menu-main.ps1'`""
            startingDirectory = $toolsRoot
            icon         = $icons.menu
            tabTitle     = 'Menu'
            suppressApplicationTitle = $true
        }
        # ── Custom profile: Projekty ──
        @{
            name         = 'Projekty'
            commandline  = 'pwsh.exe -NoExit'
            startingDirectory = Join-Path $HOME 'Projects\work'
            icon         = $icons.projects
            tabTitle     = 'Projekty'
            suppressApplicationTitle = $true
        }
        # ── Built-in profile updates (via "updates") ──
        # Updates PowerShell 7 built-in profile
        @{
            name         = 'PowerShell 7'
            commandline  = 'pwsh.exe -NoExit'
            startingDirectory = $HOME
            icon         = $icons.pwsh7
            tabTitle     = 'PS 7'
            font         = @{ face = 'CaskaydiaCove NF'; size = 12 }
            colorScheme  = 'One Half Dark'
            useAtlasEngine = $true
            antialiasingMode = 'cleartype'
        }
        # Updates Windows PowerShell 5.1 built-in profile
        @{
            name         = 'Windows PowerShell 5.1'
            commandline  = 'powershell.exe -NoExit'
            startingDirectory = $HOME
            icon         = $icons.pwsh5
            tabTitle     = 'PS 5'
        }
    )
    schemes  = @(
        @{
            name = 'One Half Dark'
            black = '#282c34'
            red = '#e06c75'
            green = '#98c379'
            yellow = '#e5c07b'
            blue = '#61afef'
            purple = '#c678dd'
            cyan = '#56b6c2'
            white = '#dcdfe4'
            brightBlack = '#282c34'
            brightRed = '#e06c75'
            brightGreen = '#98c379'
            brightYellow = '#e5c07b'
            brightBlue = '#61afef'
            brightPurple = '#c678dd'
            brightCyan = '#56b6c2'
            brightWhite = '#dcdfe4'
            background = '#000000'
            foreground = '#dcdfe4'
        }
        @{
            name = 'Dracula'
            black = '#21222c'
            red = '#ff5555'
            green = '#50fa7b'
            yellow = '#f1fa8c'
            blue = '#bd93f9'
            purple = '#ff79c6'
            cyan = '#8be9fd'
            white = '#f8f8f2'
            brightBlack = '#6272a4'
            brightRed = '#ff6e6e'
            brightGreen = '#69ff94'
            brightYellow = '#ffffa5'
            brightBlue = '#d6acff'
            brightPurple = '#ff92df'
            brightCyan = '#a4ffff'
            brightWhite = '#ffffff'
            background = '#282a36'
            foreground = '#f8f8f2'
        }
        @{
            name = 'Nord'
            black = '#3b4252'
            red = '#bf616a'
            green = '#a3be8c'
            yellow = '#ebcb8b'
            blue = '#81a1c1'
            purple = '#b48ead'
            cyan = '#88c0d0'
            white = '#e5e9f0'
            brightBlack = '#4c566a'
            brightRed = '#bf616a'
            brightGreen = '#a3be8c'
            brightYellow = '#ebcb8b'
            brightBlue = '#81a1c1'
            brightPurple = '#b48ead'
            brightCyan = '#8fbcbb'
            brightWhite = '#eceff4'
            background = '#2e3440'
            foreground = '#d8dee9'
        }
    )
}

# ── Save fragment ──────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($fragmentPath, 'Create JSON fragment')) {
    # Create directory
    if (-not (Test-Path $fragmentDir)) {
        New-Item -ItemType Directory -Path $fragmentDir -Force | Out-Null
        Write-Ok "Created fragment directory: $fragmentDir"
    }

    # Back up existing fragment
    if (Test-Path $fragmentPath) {
        $backup = "$fragmentPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $fragmentPath $backup
        Write-Ok "Backup: $backup"
    }

    # Write without BOM (UTF-8)
    $json = $fragment | ConvertTo-Json -Depth 5
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($fragmentPath, $json, $utf8NoBom)
    Write-Ok "Fragment created: $fragmentPath"

    # Also save copy to scripts/ for reference
    $refPath = Join-Path $PSScriptRoot 'profiles-fragment.json'
    [System.IO.File]::WriteAllText($refPath, $json, $utf8NoBom)
    Write-Ok "Reference copy: $refPath"
}

# ── Result ─────────────────────────────────────────────────────
Write-Host "`nDone! Restart Windows Terminal to see the new profiles." -ForegroundColor Green
Write-Host "Fragment location: $fragmentPath" -ForegroundColor Gray
Write-Host "To remove: delete the fragment file and restart WT." -ForegroundColor Gray
