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
        '1. 📥 Install / Re-install' = {
            $script = Join-Path $HOME '.config\powershell\install.ps1'
            if (Test-Path $script) {
                Write-Info "Running install.ps1..."; & $script
            } else { Write-Err "install.ps1 not found at: $script" }
            Read-Host "`nStiskni Enter..."
        }
        '2. 🔄 Update (git pull)' = {
            $script = Join-Path $HOME '.config\powershell\update.ps1'
            if (Test-Path $script) {
                Write-Info "Running update.ps1..."; & $script
            } else { Write-Err "update.ps1 not found at: $script" }
            Read-Host "`nStiskni Enter..."
        }
        '3. ⚙️  Configure Wizard' = {
            $script = Join-Path $env:DOTFILES_TOOLS 'scripts\configure.ps1'
            if (Test-Path $script) {
                & $script
            } else { Write-Err "configure.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }
        '4. 🔍 Pre-Check Inventory' = {
            $script = Join-Path $env:DOTFILES_TOOLS 'scripts\precheck.ps1'
            if (Test-Path $script) {
                & $script
            } else { Write-Err "precheck.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }
        '5. 📦 Install Dependencies' = {
            $script = Join-Path $env:DOTFILES_TOOLS 'scripts\deps.ps1'
            if (Test-Path $script) {
                Write-Info "Running deps.ps1 (this may take a while)..."
                & $script
            } else { Write-Err "deps.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }
        '6. 🪟 Windows Defaults' = {
            $script = Join-Path $env:DOTFILES_TOOLS 'scripts\windows.ps1'
            if (Test-Path $script) {
                Write-Info "Running windows.ps1..."; & $script
            } else { Write-Err "windows.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }
        '7. ↩️  Back' = { return }
    }

    Show-Menu -Title 'DOTFILES' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-DotfilesMenu
}
