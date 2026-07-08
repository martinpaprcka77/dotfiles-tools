<#
.SYNOPSIS
    Hlavní interaktivní menu.
.DESCRIPTION
    Číselné menu s položkami: Docker, Systém, Git, Nástroje, Konec.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-main.ps1
#>

function Start-MainMenu {
    $items = [ordered]@{
        '1' = { Show-DockerMenu }
        '2' = { Invoke-SystemCheck }
        '3' = { Show-GitMenu }
        '4' = { Write-Info "Nástroje – zatím prázdné."; Read-Host "`nStiskni Enter..." }
        '5' = { break }
    }

    Show-Menu -Title 'HLAVNÍ MENU' -Items $items
}

# If run directly (not dot-sourced), execute menu
if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Start-MainMenu
}
