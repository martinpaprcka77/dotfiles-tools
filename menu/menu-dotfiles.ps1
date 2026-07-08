<#
.SYNOPSIS
    Dotfiles ecosystem management menu.
.DESCRIPTION
    Install, update, configure, and diagnose the dotfiles ecosystem.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-dotfiles.ps1
#>

function Show-DotfilesMenu {
    $items = [ordered]@{
        '1. 📥 Install/Reinstall'  = @{ Action = {
            $s = Join-Path $HOME '.config\powershell\install.ps1'
            if (Test-Path $s) { & $s } else { Write-Err "install.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Run install.ps1 — idempotent, safe to re-run' }
        '2. 🔄 Update (git pull)'  = @{ Action = {
            $s = Join-Path $HOME '.config\powershell\update.ps1'
            if (Test-Path $s) { & $s } else { Write-Err "update.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Git pull latest + reload profile' }
        '3. ⚙️  Configure Wizard'   = @{ Action = {
            $s = Join-Path $env:DOTFILES_TOOLS 'scripts\configure.ps1'
            if (Test-Path $s) { & $s } else { Write-Err "configure.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Interactive 5-step setup wizard' }
        '4. 🔍 Pre-Check'          = @{ Action = {
            $s = Join-Path $env:DOTFILES_TOOLS 'scripts\precheck.ps1'
            if (Test-Path $s) { & $s } else { Write-Err "precheck.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = '30+ inventory checks before install' }
        '5. 📦 Dependencies'       = @{ Action = {
            $s = Join-Path $env:DOTFILES_TOOLS 'scripts\deps.ps1'
            if (Test-Path $s) { Write-Info "Running deps.ps1..."; & $s } else { Write-Err "deps.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Winget auto-installer: Git, PS7, WT, VS Code, Starship' }
        '6. 🪟 Windows Defaults'   = @{ Action = {
            $s = Join-Path $env:DOTFILES_TOOLS 'scripts\windows.ps1'
            if (Test-Path $s) { & $s } else { Write-Err "windows.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Explorer, taskbar, privacy, bloatware removal' }
        '7. ↩️  Back'              = @{ Action = { return }; Desc = 'Return to main menu' }
    }
    Show-Menu -Title 'DOTFILES' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-DotfilesMenu
}
