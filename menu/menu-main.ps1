<#
.SYNOPSIS
    Hlavní interaktivní menu.
.DESCRIPTION
    Modern menu with arrow-key navigation. Items: Docker, System, Git, Tools, Exit.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-main.ps1
#>

function Start-MainMenu {
    $items = [ordered]@{
        '1. 🐳 Docker'     = { Show-DockerMenu }
        '2. 🔍 Diagnostika' = { Invoke-SystemCheck }
        '3. 📋 Git'         = { Show-GitMenu }
        '4. 🔧 Nástroje'    = { Write-Info "Nástroje — zatím prázdné."; Read-Host "`nStiskni Enter..." }
        '5. 🚪 Exit'        = { return }
    }

    Show-Menu -Title 'HLAVNÍ MENU' -Items $items
}

# If run directly (not dot-sourced), execute menu
if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Start-MainMenu
}
