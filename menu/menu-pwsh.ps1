<#
.SYNOPSIS
    PowerShell profile and environment management menu.
.DESCRIPTION
    Edit profile, reload, benchmark, view modules/aliases/functions.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-pwsh.ps1
#>

function Show-PwshMenu {
    $items = [ordered]@{
        '1. ✏️  Edit Profile' = {
            $profilePath = Join-Path $HOME '.config\powershell\profile.ps1'
            $editor = if ($env:EDITOR) { $env:EDITOR } elseif (Get-Command code -ErrorAction SilentlyContinue) { 'code' } else { 'notepad' }
            Write-Info "Opening $profilePath with $editor..."
            & $editor $profilePath
        }
        '2. 🔄 Reload Profile' = {
            Write-Info "Reloading profile..."
            $profilePath = Join-Path $HOME '.config\powershell\profile.ps1'
            if (Test-Path $profilePath) {
                . $profilePath
                Write-Success "Profile reloaded."
            } else { Write-Err "profile.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }
        '3. ⏱️  Benchmark Profile' = {
            Write-Info "Measuring profile load time..."
            $env:PROFILE_BENCHMARK = 'true'
            $profilePath = Join-Path $HOME '.config\powershell\profile.ps1'
            if (Test-Path $profilePath) {
                $sw = [Diagnostics.Stopwatch]::StartNew()
                . $profilePath
                $sw.Stop()
                Write-Success "Profile loaded in $($sw.ElapsedMilliseconds)ms"
            }
            $env:PROFILE_BENCHMARK = $null
            Read-Host "`nStiskni Enter..."
        }
        '4. 📦 Loaded Modules' = {
            Write-Host "`n  Loaded modules:" -ForegroundColor Cyan
            Get-Module | Where-Object { $_.Name -notmatch '^Microsoft\.|^Cim|^PSReadLine$' } |
                Select-Object Name, Version |
                Sort-Object Name |
                ForEach-Object { Write-Host "    $($_.Name) v$($_.Version)" -ForegroundColor White }
            Read-Host "`nStiskni Enter..."
        }
        '5. 🔤 Active Aliases' = {
            Write-Host "`n  Custom aliases:" -ForegroundColor Cyan
            Get-Alias | Where-Object { $_.Options -eq 'None' -or $_.Options -eq 'ReadOnly' } |
                Select-Object Name, Definition |
                Sort-Object Name |
                ForEach-Object { Write-Host "    $($_.Name) → $($_.Definition)" -ForegroundColor White }
            Read-Host "`nStiskni Enter..."
        }
        '6. 🔧 Toolkit Functions' = {
            Write-Host "`n  Toolkit module functions (19):" -ForegroundColor Cyan
            Get-Command -Module Toolkit -ErrorAction SilentlyContinue |
                Sort-Object Name |
                ForEach-Object { Write-Host "    $($_.Name)" -ForegroundColor White }
            if (-not (Get-Module Toolkit)) {
                Write-Warn "Toolkit module not loaded. Run: Import-Module ~/Projects/tools/Toolkit/Toolkit.psd1"
            }
            Read-Host "`nStiskni Enter..."
        }
        '7. ↩️  Back' = { return }
    }

    Show-Menu -Title 'POWERSHELL' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-PwshMenu
}
