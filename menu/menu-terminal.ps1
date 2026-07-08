<#
.SYNOPSIS
    Windows Terminal management menu.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-terminal.ps1
#>

function Show-TerminalMenu {
    $items = [ordered]@{
        '1. 🔄 Generate Profiles' = @{ Action = {
            $s = Join-Path $env:DOTFILES_TOOLS 'scripts\Add-WTProfiles.ps1'
            if (Test-Path $s) { & $s } else { Write-Err "Add-WTProfiles.ps1 not found" }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Create/update WT JSON fragment with 4 profiles + 7 schemes' }
        '2. 🎨 Color Schemes'     = @{ Action = {
            $fp = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json"
            if (-not (Test-Path $fp)) { Write-Warn "Fragment not found. Run Generate Profiles first."; Read-Host "`nStiskni Enter..."; return }
            $f = Get-Content $fp -Raw | ConvertFrom-Json
            $schemes = $f.schemes | ForEach-Object { $_.name }
            Write-Host "`n  Available schemes:" -ForegroundColor Cyan
            for ($i = 0; $i -lt $schemes.Count; $i++) { Write-Host "    $($i+1). $($schemes[$i])" }
            $c = Read-Host "`n  Pick (1-$($schemes.Count))"
            if ($c -match '^\d+$' -and [int]$c -ge 1 -and [int]$c -le $schemes.Count) {
                Write-Success "Selected: $($schemes[[int]$c-1]) — regenerate fragment to apply"
            }
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Browse 7 built-in color schemes (One Half Dark, Dracula, Nord, ...)' }
        '3. 🔤 Fonts'            = @{ Action = {
            Write-Host "`n  Recommended Nerd Fonts:" -ForegroundColor Cyan
            $f = @('CaskaydiaCove NF (installed)', 'Cascadia Code PL (ships with WT)', 'JetBrainsMono NF', 'FiraCode NF', 'Hack NF', 'MesloLGS NF')
            $f | ForEach-Object { Write-Host "    $_" }
            Write-Host "`n  💡 Set in WT → Settings → Profiles → Appearance → Font face" -ForegroundColor Yellow
            Read-Host "`nStiskni Enter..."
        }; Desc = '6 Nerd Font recommendations with install sources' }
        '4. 🔌 Shell Integration' = @{ Action = {
            Write-Host "`n  Status:" -ForegroundColor Cyan
            $fp = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json"
            if (Test-Path $fp) {
                $f = Get-Content $fp -Raw | ConvertFrom-Json
                $p = $f.profiles | Where-Object { $_.name -eq 'PowerShell 7' }
                Write-Host "    showMarksOnScrollbar: $(if($p.showMarksOnScrollbar){'✅ ON'}else{'❌ OFF'})"
                Write-Host "    autoMarkPrompts:      $(if($p.autoMarkPrompts){'✅ ON'}else{'❌ OFF'})"
            }
            Write-Host "`n  OSC 133 markers active from: hosts/shell-integration.ps1" -ForegroundColor DarkGray
            Read-Host "`nStiskni Enter..."
        }; Desc = 'Command marks, scrollbar dots, Ctrl+Up/Down navigation' }
        '5. ↩️  Back'             = @{ Action = { return }; Desc = 'Return to main menu' }
    }
    Show-Menu -Title 'TERMINAL' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-TerminalMenu
}
