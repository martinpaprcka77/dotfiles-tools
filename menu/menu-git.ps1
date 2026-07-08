<#
.SYNOPSIS
    Git submenu with arrow-key navigation.
.DESCRIPTION
    Quick Git operations — status, log, branch, remote, stash, commit.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-git.ps1
#>

function Show-GitMenu {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Err "Git není nainstalován nebo není v PATH."
        Read-Host "`nStiskni Enter..."
        return
    }

    $items = [ordered]@{
        '1. 📋 Status'      = { git status; Read-Host "`nStiskni Enter..." }
        '2. 📜 Log'         = { git log --oneline --graph --decorate -20; Read-Host "`nStiskni Enter..." }
        '3. 🌿 Branches'    = { git branch -a; Read-Host "`nStiskni Enter..." }
        '4. 🔗 Remotes'     = { git remote -v; Read-Host "`nStiskni Enter..." }
        '5. 📦 Stash'       = { git stash list; Read-Host "`nStiskni Enter..." }
        '6. 💾 Quick Commit' = { $msg = Read-Host 'Commit message'; git commit -am $msg 2>&1; Read-Host "`nStiskni Enter..." }
        '7. ↩️  Back'        = { return }
    }

    Show-Menu -Title 'GIT' -Items $items
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-GitMenu
}
