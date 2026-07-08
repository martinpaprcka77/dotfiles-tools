<#
.SYNOPSIS
    Přidá/aktualizuje profily ve Windows Terminálu.
.DESCRIPTION
    Najde settings.json, zálohuje jej, odstraní komentáře, přidá 4 profily
    s pevnými GUID a uloží bez BOM. Podporuje -WhatIf.
.PARAMETER WhatIf
    Pouze zobrazí, co by se provedlo, beze změn.
.EXAMPLE
    .\Add-WTProfiles.ps1
    .\Add-WTProfiles.ps1 -WhatIf
.NOTES
    GUID profilů:
    Menu:      {11111111-1111-1111-1111-111111111111}
    Projekty:  {22222222-2222-2222-2222-222222222222}
    PS7:       {33333333-3333-3333-3333-333333333333}
    PS5:       {44444444-4444-4444-4444-444444444444}
    Cesta: ~/Projects/tools/scripts/Add-WTProfiles.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param()

# Cross-platform guard — Windows Terminal only exists on Windows
if ($IsLinux -or $IsMacOS) {
    Write-Error "Add-WTProfiles.ps1 requires Windows. This is a Linux/macOS system."
    exit 1
}

$ErrorActionPreference = 'Stop'

#region Find settings.json
$possiblePaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)

$settingsPath = $null
foreach ($p in $possiblePaths) {
    if (Test-Path $p) {
        $settingsPath = $p
        break
    }
}

if (-not $settingsPath) {
    Write-Error "Nenalezen settings.json Windows Terminálu."
    exit 1
}

Write-Info "Nalezen: $settingsPath"
#endregion

#region Backup
$backupPath = "$settingsPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
if ($PSCmdlet.ShouldProcess($settingsPath, "Zálohovat do $backupPath")) {
    Copy-Item $settingsPath $backupPath
    Write-Success "Záloha uložena: $backupPath"
}
#endregion

#region Remove comments and parse JSON
$raw = Get-Content $settingsPath -Raw

# Remove // comments (line-based)
$lines = $raw -split "`r?`n"
$cleanLines = $lines | ForEach-Object {
    if ($_ -match '^\s*//') { return $null }
    $_ -replace '\s*//.*$', ''
}
$cleanJson = ($cleanLines | Where-Object { $_ -ne $null -and $_.Trim() -ne '' }) -join "`n"

try {
    $settings = $cleanJson | ConvertFrom-Json -Depth 20 -ErrorAction Stop
}
catch {
    Write-Error "Nepodařilo se parsovat JSON: $_"
    Write-Info "Zkontroluj $backupPath"
    exit 1
}
#endregion

#region Define profiles
$toolsRoot = Join-Path $HOME 'Projects\tools'
$iconsDir = Join-Path $toolsRoot 'icons'

$newProfiles = @(
    [PSCustomObject]@{
        guid    = '{11111111-1111-1111-1111-111111111111}'
        name    = 'Menu'
        command = 'pwsh.exe'
        args    = '-NoExit', '-Command', "& '$toolsRoot\menu\menu-main.ps1'"
        icon    = Join-Path $iconsDir 'menu.png'
    },
    [PSCustomObject]@{
        guid    = '{22222222-2222-2222-2222-222222222222}'
        name    = 'Projekty'
        command = 'pwsh.exe'
        args    = '-NoExit', '-Command', "Set-Location '$HOME\Projects\work'"
        icon    = Join-Path $iconsDir 'projects.png'
    },
    [PSCustomObject]@{
        guid    = '{33333333-3333-3333-3333-333333333333}'
        name    = 'PowerShell 7'
        command = 'pwsh.exe'
        args    = '-NoExit'
        icon    = Join-Path $iconsDir 'pwsh7.png'
    },
    [PSCustomObject]@{
        guid    = '{44444444-4444-4444-4444-444444444444}'
        name    = 'Windows PowerShell 5.1'
        command = 'powershell.exe'
        args    = '-NoExit'
        icon    = Join-Path $iconsDir 'pwsh5.png'
    }
)
#endregion

#region Update profiles list
if (-not $settings.profiles) {
    $settings | Add-Member -MemberType NoteProperty -Name 'profiles' -Value ([PSCustomObject]@{}) -Force
}
if (-not $settings.profiles.list) {
    $settings.profiles | Add-Member -MemberType NoteProperty -Name 'list' -Value @() -Force
}

$profileList = [System.Collections.ArrayList]($settings.profiles.list)

foreach ($new in $newProfiles) {
    $existing = $profileList | Where-Object { $_.guid -eq $new.guid }

    # Check icons
    $iconPath = if (Test-Path $new.icon) { $new.icon } else { $null }

    $profileObj = [PSCustomObject]@{
        guid    = $new.guid
        name    = $new.name
        commandline = $new.command
        commandlineArgs = $new.args -join ' '
        icon    = $iconPath
        hidden  = $false
    }

    if ($existing) {
        $index = $profileList.IndexOf($existing)
        if ($PSCmdlet.ShouldProcess($new.name, "Aktualizovat profil")) {
            $profileList[$index] = $profileObj
            Write-Success "Aktualizován profil: $($new.name)"
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess($new.name, "Přidat profil")) {
            $profileList.Add($profileObj) | Out-Null
            Write-Success "Přidán profil: $($new.name)"
        }
    }
}

$settings.profiles.list = $profileList.ToArray()
#endregion

#region Save settings (without BOM)
if ($PSCmdlet.ShouldProcess($settingsPath, "Uložit nastavení")) {
    $json = $settings | ConvertTo-Json -Depth 20
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($settingsPath, $json, $utf8NoBom)
    Write-Success "Nastavení uloženo."
}
#endregion

#region Generate profiles-fragment.json
$fragmentPath = Join-Path $PSScriptRoot 'profiles-fragment.json'
$fragment = [PSCustomObject]@{
    profiles = [PSCustomObject]@{
        list = @($newProfiles | ForEach-Object {
            [PSCustomObject]@{
                guid    = $_.guid
                name    = $_.name
                commandline = $_.command
                icon    = if (Test-Path $_.icon) { $_.icon } else { $null }
            }
        })
    }
}
$fragmentJson = $fragment | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($fragmentPath, $fragmentJson, (New-Object System.Text.UTF8Encoding $false))
Write-Info "Fragment vygenerován: $fragmentPath"
#endregion

Write-Host "`nHotovo! Restartuj Windows Terminal." -ForegroundColor Green
