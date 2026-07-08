<#
.SYNOPSIS
    Hlavní interaktivní menu.
.DESCRIPTION
    Modern arrow-key menu with organized categories:
    Dotfiles, Docker, Git, Terminal, PowerShell, VS Code, System.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-main.ps1
#>

function Start-MainMenu {
    $items = [ordered]@{
        '1. ⚡ Dotfiles'      = { Show-DotfilesMenu }
        '2. 🔍 Diagnostika'   = { Invoke-SystemCheck }
        '3. 🐳 Docker'        = { Show-DockerMenu }
        '4. 📋 Git'           = { Show-GitMenu }
        '5. 🖥️  Terminal'      = { Show-TerminalMenu }
        '6. 💻 PowerShell'    = { Show-PwshMenu }
        '7. 📝 VS Code'       = { Show-VSCodeMenu }
        '8. 🚪 Exit'          = { return }
    }

    Show-Menu -Title 'HLAVNÍ MENU' -Items $items
}

# If run directly (not dot-sourced), execute menu
if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Start-MainMenu
}
