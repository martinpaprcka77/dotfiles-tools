<#
.SYNOPSIS
    VS Code management menu.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-vscode.ps1
#>

function Show-VSCodeMenu {
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Err "VS Code (code) is not in PATH."
        Read-Host "`nStiskni Enter..."; return
    }
    $vsc = Join-Path $env:DOTFILES_TOOLS '.vscode'
    $items = [ordered]@{
        '1. 📄 Settings'       = @{ Action = {
            $p = Join-Path $vsc 'settings.json'
            if (Test-Path $p) { code $p } else { Write-Err "Not found: $p" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Open committed settings.json (Nerd Font, terminal profiles, shell integration)' }
        '2. ⚡ Tasks'          = @{ Action = {
            $p = Join-Path $vsc 'tasks.json'
            if (Test-Path $p) { code $p } else { Write-Err "Not found: $p" }
            Read-Host "`nStiskni Enter..."
        }; Desc = '5 tasks: Pester, install, update, WT fragment, deps' }
        '3. 🤖 Agent'         = @{ Action = {
            $p = Join-Path $vsc 'agent-instructions.md'
            if (Test-Path $p) { code $p } else { Write-Err "Not found: $p" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Copilot/GPT-4/Claude context file (read via #codebase)' }
        '4. 🧩 Extensions'    = @{ Action = {
            Write-Host "`n  PowerShell extensions:" -ForegroundColor Cyan
            code --list-extensions 2>&1 | Select-String 'powershell|terminal|copilot' | ForEach-Object { Write-Host "    $_" }
            Write-Host "`n  Recommended: ms-vscode.powershell, GitHub.copilot, GitHub.copilot-chat" -ForegroundColor Yellow
            Read-Host "`nStiskni Enter..."
        }; Desc = 'List PowerShell-related VS Code extensions' }
        '5. 🖥️  Open Folder'   = @{ Action = {
            code $env:DOTFILES_TOOLS
        }; Desc = 'Open ~/Projects/tools in VS Code' }
        '6. ↩️  Back'          = @{ Action = { return }; Desc = 'Return to main menu' }
    }
    Show-Menu -Title 'VS CODE' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-VSCodeMenu
}
