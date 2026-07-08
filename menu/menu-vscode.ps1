<#
.SYNOPSIS
    VS Code management menu.
.DESCRIPTION
    View/edit VS Code settings, tasks, agent instructions, extensions.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-vscode.ps1
#>

function Show-VSCodeMenu {
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Err "VS Code (code) není v PATH."
        Read-Host "`nStiskni Enter..."
        return
    }

    $vscDir = Join-Path $env:DOTFILES_TOOLS '.vscode'

    $items = [ordered]@{
        '1. 📄 View/Edit Settings' = {
            $path = Join-Path $vscDir 'settings.json'
            if (Test-Path $path) {
                Write-Info "Opening $path..."
                code $path
            } else { Write-Err "settings.json not found at: $path" }
            Read-Host "`nStiskni Enter..."
        }
        '2. ⚡ View/Edit Tasks' = {
            $path = Join-Path $vscDir 'tasks.json'
            if (Test-Path $path) {
                Write-Info "Opening $path..."
                code $path
            } else { Write-Err "tasks.json not found at: $path" }
            Read-Host "`nStiskni Enter..."
        }
        '3. 🤖 Agent Instructions' = {
            $path = Join-Path $vscDir 'agent-instructions.md'
            if (Test-Path $path) {
                Write-Info "Opening $path..."
                code $path
            } else { Write-Err "agent-instructions.md not found at: $path" }
            Read-Host "`nStiskni Enter..."
        }
        '4. 🧩 Installed Extensions' = {
            Write-Host "`n  PowerShell-related extensions:" -ForegroundColor Cyan
            $exts = code --list-extensions 2>&1 | Select-String -Pattern 'powershell|terminal|copilot'
            if ($exts) {
                $exts | ForEach-Object { Write-Host "    $_" -ForegroundColor White }
            } else {
                Write-Host "    (no PowerShell extensions found)" -ForegroundColor DarkGray
            }
            Write-Host "`n  Recommended:" -ForegroundColor Yellow
            Write-Host "    ms-vscode.powershell" -ForegroundColor DarkGray
            Write-Host "    GitHub.copilot" -ForegroundColor DarkGray
            Write-Host "    GitHub.copilot-chat" -ForegroundColor DarkGray
            Read-Host "`nStiskni Enter..."
        }
        '5. 🖥️  Open in VS Code' = {
            Write-Info "Opening ~/Projects/tools in VS Code..."
            code $env:DOTFILES_TOOLS
        }
        '6. ↩️  Back' = { return }
    }

    Show-Menu -Title 'VS CODE' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-VSCodeMenu
}
