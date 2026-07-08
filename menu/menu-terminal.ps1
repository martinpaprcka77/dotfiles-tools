<#
.SYNOPSIS
    Windows Terminal management menu with arrow-key navigation.
.DESCRIPTION
    Manage WT profiles, fonts, color schemes, shell integration, and fragment.
    Shows font recommendations, lets you switch schemes, regenerate fragment.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-terminal.ps1
#>

function Show-TerminalMenu {
    $items = [ordered]@{
        '1. 🔄 Generate/Update Profiles' = {
            $script = Join-Path $env:DOTFILES_TOOLS 'scripts\Add-WTProfiles.ps1'
            if (Test-Path $script) {
                Write-Info "Running Add-WTProfiles.ps1..."
                & $script
            } else {
                Write-Err "Add-WTProfiles.ps1 not found at: $script"
            }
            Read-Host "`nStiskni Enter..."
        }
        '2. 🎨 Switch Color Scheme' = {
            $fragmentPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json"
            if (-not (Test-Path $fragmentPath)) {
                Write-Warn "Fragment not found. Run 'Generate/Update Profiles' first."
                Read-Host "`nStiskni Enter..."
                return
            }
            $fragment = Get-Content $fragmentPath -Raw | ConvertFrom-Json
            $schemes = $fragment.schemes | ForEach-Object { $_.name }

            Write-Host "`n  Available color schemes:" -ForegroundColor Cyan
            for ($i = 0; $i -lt $schemes.Count; $i++) {
                Write-Host "    $($i+1). $($schemes[$i])" -ForegroundColor White
            }

            $choice = Read-Host "`n  Choose scheme (1-$($schemes.Count))"
            if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $schemes.Count) {
                $selected = $schemes[[int]$choice - 1]
                Write-Info "Selected: $selected"
                Write-Host "  To apply: re-run 'Generate/Update Profiles' or manually set in WT Settings → Appearance → Color scheme → '$selected'" -ForegroundColor Yellow
            }
            Read-Host "`nStiskni Enter..."
        }
        '3. 🔤 Font Recommendations' = {
            Write-Host "`n  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
            Write-Host   "  ║   RECOMMENDED TERMINAL FONTS              ║" -ForegroundColor Cyan
            Write-Host   "  ╚══════════════════════════════════════════╝`n" -ForegroundColor Cyan

            $fonts = @(
                @{ N = 'CaskaydiaCove NF'; D = 'Cascadia Code + Nerd Font glyphs (default)'; S = '✅ installed (via deps.ps1)' },
                @{ N = 'Cascadia Code PL';  D = 'Cascadia Code with Powerline glyphs';         S = '📦 ships with Windows Terminal' },
                @{ N = 'JetBrainsMono NF';  D = 'JetBrains Mono + Nerd Font (developer fav)';  S = '📥 winget install DEVCOM.JetBrainsMonoNerdFont' },
                @{ N = 'FiraCode NF';       D = 'Fira Code with ligatures + Nerd Font';         S = '📥 https://github.com/ryanoasis/nerd-fonts' },
                @{ N = 'Hack NF';           D = 'Hack — no ligatures, clean, readable';         S = '📥 https://github.com/ryanoasis/nerd-fonts' },
                @{ N = 'MesloLGS NF';       D = 'Meslo — default for oh-my-posh/powerlevel10k'; S = '📥 https://github.com/romkatv/powerlevel10k-media' }
            )

            foreach ($f in $fonts) {
                Write-Host "  $($PSStyle.Foreground.BrightGreen)$($f.N)$($PSStyle.Reset)" -NoNewline
                Write-Host " — $($f.D)" -ForegroundColor Gray
                Write-Host "    $($f.S)" -ForegroundColor DarkGray
            }

            Write-Host "`n  💡 Tip: Nerd Fonts (NF) include 9000+ icons for Starship, oh-my-posh." -ForegroundColor Yellow
            Write-Host "  💡 Set in WT: Settings → Profiles → PowerShell 7 → Appearance → Font face" -ForegroundColor Yellow
            Read-Host "`nStiskni Enter..."
        }
        '4. 🔌 Shell Integration Status' = {
            Write-Host "`n  Shell Integration Features:" -ForegroundColor Cyan
            $fragmentPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json"
            if (Test-Path $fragmentPath) {
                $fragment = Get-Content $fragmentPath -Raw | ConvertFrom-Json
                $ps7 = $fragment.profiles | Where-Object { $_.name -eq 'PowerShell 7' }
                $marks = if ($ps7.showMarksOnScrollbar) { '✅ ON' } else { '❌ OFF' }
                $auto  = if ($ps7.autoMarkPrompts) { '✅ ON' } else { '❌ OFF' }
                Write-Host "    showMarksOnScrollbar: $marks" -ForegroundColor White
                Write-Host "    autoMarkPrompts:      $auto" -ForegroundColor White
            } else {
                Write-Warn "Fragment not found. Run 'Generate/Update Profiles' first."
            }

            Write-Host "`n  Shell integration is loaded from:" -ForegroundColor DarkGray
            Write-Host "    ~/.config/powershell/hosts/shell-integration.ps1" -ForegroundColor DarkGray
            Write-Host "`n  Manual actions to add to WT settings.json:" -ForegroundColor Yellow
            Write-Host '    { "keys": "ctrl+up",   "command": { "action": "scrollToMark", "direction": "previous" } }' -ForegroundColor DarkGray
            Write-Host '    { "keys": "ctrl+down", "command": { "action": "scrollToMark", "direction": "next" } }' -ForegroundColor DarkGray
            Read-Host "`nStiskni Enter..."
        }
        '5. 📄 View Fragment' = {
            $fragmentPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json"
            if (Test-Path $fragmentPath) {
                Write-Host "`n  Fragment: $fragmentPath" -ForegroundColor Cyan
                Write-Host "  $(('─' * 60))" -ForegroundColor DarkGray
                Get-Content $fragmentPath | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Warn "Fragment not found. Run 'Generate/Update Profiles' first."
            }
            Read-Host "`nStiskni Enter..."
        }
        '6. ↩️  Back' = { return }
    }

    Show-Menu -Title 'TERMINAL' -Items $items
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-TerminalMenu
}
