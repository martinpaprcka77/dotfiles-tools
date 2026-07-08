<#
.SYNOPSIS
    PowerShell profile and environment management menu.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-pwsh.ps1
#>

function Show-PwshMenu {
    $items = [ordered]@{
        '1. ✏️  Edit Profile'   = @{ Action = {
            $p = Join-Path $HOME '.config\powershell\profile.ps1'
            $e = if ($env:EDITOR) { $env:EDITOR } elseif (Get-Command code -ErrorAction SilentlyContinue) { 'code' } else { 'notepad' }
            & $e $p
        }; Desc = 'Open profile.ps1 in editor' }
        '2. 🔄 Reload Profile' = @{ Action = {
            $p = Join-Path $HOME '.config\powershell\profile.ps1'
            if (Test-Path $p) { . $p; Write-Success "Profile reloaded." } else { Write-Err "Not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Re-source profile without restart' }
        '3. ⏱️  Benchmark'      = @{ Action = {
            $env:PROFILE_BENCHMARK = 'true'
            $p = Join-Path $HOME '.config\powershell\profile.ps1'
            if (Test-Path $p) { $sw = [Diagnostics.Stopwatch]::StartNew(); . $p; $sw.Stop(); Write-Success "Loaded in $($sw.ElapsedMilliseconds)ms" }
            $env:PROFILE_BENCHMARK = $null
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Measure profile load time' }
        '4. 📦 Modules'        = @{ Action = {
            Write-Host "`n  Loaded modules:" -ForegroundColor Cyan
            Get-Module | Where-Object { $_.Name -notmatch '^Microsoft\.|^Cim|^PSReadLine$' } | Select Name, Version | Sort Name | ForEach-Object { Write-Host "    $($_.Name) v$($_.Version)" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'List all loaded PowerShell modules' }
        '5. ⚡ Performance'     = @{ Action = {
            $sub = [ordered]@{
                '1. Run Benchmark'     = @{ Action = { Measure-Profile }; Desc = 'Detailed step-by-step timing breakdown' }
                '2. Module Analysis'   = @{ Action = { Optimize-ModuleLoading }; Desc = 'Lazy loading suggestions per module' }
                '3. Profile Size'      = @{ Action = { Get-ProfileSize }; Desc = 'Lines, bytes, file count' }
                '4. Clear Cache'       = @{ Action = { Clear-PSCache }; Desc = 'Clean corrupted module/startup caches' }
                '5. ↩️  Back'           = @{ Action = { return }; Desc = '' }
            }
            Show-Menu -Title 'PERFORMANCE' -Items $sub
        }; Desc = 'Benchmark, analyze, optimize, clear caches' }
        '6. 🔧 Functions'      = @{ Action = {
            Write-Host "`n  Toolkit functions (22):" -ForegroundColor Cyan
            Get-Command -Module Toolkit -ErrorAction SilentlyContinue | Sort Name | ForEach-Object { Write-Host "    $($_.Name)" }
            if (-not (Get-Module Toolkit)) { Write-Warn "Toolkit not loaded." }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'All 22 exported Toolkit functions' }
        '7. ↩️  Back'           = @{ Action = { return }; Desc = 'Return to main menu' }
    }
    Show-Menu -Title 'POWERSHELL' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-PwshMenu
}
