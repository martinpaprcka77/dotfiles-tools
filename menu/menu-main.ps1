<#
.SYNOPSIS
    Hlavní interaktivní menu — kořen celého systému.
.DESCRIPTION
    Modern arrow-key menu with descriptions and inline execution.
    Submenus roll down below the menu instead of taking over the screen.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-main.ps1
#>

function Start-MainMenu {
    $items = [ordered]@{
        '1. ⚡ Dotfiles'   = @{ Action = { Show-DotfilesMenu };   Desc = 'Install, update, configure, precheck, deps, windows' }
        '2. 🔍 Systém'     = @{ Action = { Invoke-SystemCheck };  Desc = 'Disk, services, network, top processes' }
        '3. 🐳 Docker'     = @{ Action = { Show-DockerMenu };     Desc = 'Containers, images, stats, logs' }
        '4. 📋 Git'        = @{ Action = { Show-GitMenu };        Desc = 'Status, log, branches, remotes, stash, commit' }
        '5. 🖥️  Terminal'   = @{ Action = { Show-TerminalMenu };   Desc = 'Profiles, color schemes, fonts, shell integration' }
        '6. 💻 PowerShell' = @{ Action = { Show-PwshMenu };       Desc = 'Edit, reload, benchmark, modules, performance' }
        '7. 📝 VS Code'    = @{ Action = { Show-VSCodeMenu };     Desc = 'Settings, tasks, agent, extensions' }
        '8. 🚪 Exit'       = @{ Action = { return };              Desc = 'Close the menu' }
    }

    Show-Menu -Title 'HLAVNÍ MENU' -Items $items -Inline
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Start-MainMenu
}
