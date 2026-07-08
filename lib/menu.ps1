<#
.SYNOPSIS
    Modern interactive menu engine with arrow-key navigation.
.DESCRIPTION
    Renders a highlighted menu using box-drawing characters. Supports:
    - ↑↓ arrow keys to move selection
    - Enter to confirm
    - Number keys for direct selection
    - Escape / q to exit
    - Configurable color scheme via Get-ToolkitConfig
.PARAMETER Title
    Menu title displayed at the top.
.PARAMETER Items
    Ordered hashtable: key = "N. Label", value = { scriptblock }.
    Keys are sorted alphabetically; numeric prefixes control order.
.EXAMPLE
    Show-Menu -Title "MAIN MENU" -Items ([ordered]@{
        "1. Docker"    = { Show-DockerMenu }
        "2. System"    = { Invoke-SystemCheck }
        "5. Exit"      = { return }
    })
.NOTES
    Cesta: ~/Projects/tools/lib/menu.ps1
    Requires console host that supports [Console]::ReadKey (ConsoleHost, WT).
#>

function Show-Menu {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [hashtable]$Items
    )

    # ── Get ordered keys ───────────────────────────────────────
    $keys = @($Items.Keys | Sort-Object)
    if ($keys.Count -eq 0) { Write-Warn "Menu has no items."; return }

    # ── Load color config ──────────────────────────────────────
    $accent = 'Cyan'
    $highlightFg = 'Black'
    $highlightBg = 'Cyan'
    try {
        $cfg = Get-ToolkitConfig -ErrorAction SilentlyContinue
        if ($cfg -and $cfg.menu.colorScheme) {
            $accent = $cfg.menu.colorScheme
            $highlightFg = 'Black'
            $highlightBg = $accent
        }
    } catch { }

    # ── Hide cursor, prepare ───────────────────────────────────
    $prevCursor = [Console]::CursorVisible
    [Console]::CursorVisible = $false
    $selected = 0
    $maxWidth = ($keys | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum + 3
    $footer = "↑↓ navigate  ↵ select  Esc/q exit"

    # ── Render loop ────────────────────────────────────────────
    do {
        # Save cursor position and clear previous render
        [Console]::SetCursorPosition(0, [Console]::CursorTop)
        $startTop = [Console]::CursorTop

        # ── Draw header ────────────────────────────────────────
        Write-Host ""
        Write-Host "  ╭$('─' * [Math]::Max($Title.Length + 2, $maxWidth + 2))╮" -ForegroundColor DarkGray
        Write-Host "  │ " -ForegroundColor DarkGray -NoNewline
        Write-Host $Title.PadRight([Math]::Max($Title.Length, $maxWidth)) -ForegroundColor $accent -NoNewline
        Write-Host " │" -ForegroundColor DarkGray
        Write-Host "  ╰$('─' * [Math]::Max($Title.Length + 2, $maxWidth + 2))╯" -ForegroundColor DarkGray
        Write-Host ""

        # ── Draw items ─────────────────────────────────────────
        for ($i = 0; $i -lt $keys.Count; $i++) {
            $key = $keys[$i]
            $label = "  $key"
            $pad = [Math]::Max(0, $maxWidth - $key.Length + 1)

            if ($i -eq $selected) {
                Write-Host " ▸ " -ForegroundColor $accent -NoNewline
                Write-Host $key -ForegroundColor $highlightFg -BackgroundColor $highlightBg -NoNewline
                Write-Host (' ' * $pad) -BackgroundColor $highlightBg
                Write-Host ""  # reset background
            } else {
                Write-Host "   " -NoNewline
                Write-Host $key -ForegroundColor White
            }
        }

        # ── Draw footer ────────────────────────────────────────
        Write-Host ""
        Write-Host "  $footer" -ForegroundColor DarkGray

        # ── Clear below (in case menu shrank) ──────────────────
        $endTop = [Console]::CursorTop
        for ($r = $endTop; $r -le $startTop + $keys.Count + 6; $r++) {
            [Console]::SetCursorPosition(0, $r)
            Write-Host (' ' * ($maxWidth + 10)) -NoNewline
        }
        [Console]::SetCursorPosition(0, $endTop)

        # ── Read key ───────────────────────────────────────────
        $keyInfo = [Console]::ReadKey($true)
        switch ($keyInfo.Key) {
            'UpArrow'    { $selected = if ($selected -gt 0) { $selected - 1 } else { $keys.Count - 1 } }
            'DownArrow'  { $selected = if ($selected -lt $keys.Count - 1) { $selected + 1 } else { 0 } }
            'Enter'      {
                $chosenKey = $keys[$selected]
                $action = $Items[$chosenKey]
                [Console]::CursorVisible = $prevCursor
                Clear-Host
                if ($action -is [scriptblock]) { & $action }
                return
            }
            'Escape'     { [Console]::CursorVisible = $prevCursor; Clear-Host; return }
            'Q'          { [Console]::CursorVisible = $prevCursor; Clear-Host; return }
            default {
                # Number key shortcut (D0-D9 = 0-9)
                $num = $null
                if ($keyInfo.Key -ge 'D0' -and $keyInfo.Key -le 'D9') {
                    $num = [int]($keyInfo.Key - 'D0')
                } elseif ($keyInfo.Key -ge 'NumPad0' -and $keyInfo.Key -le 'NumPad9') {
                    $num = [int]($keyInfo.Key - 'NumPad0')
                }
                if ($num -ne $null) {
                    $match = $keys | Where-Object { $_ -match "^\s*${num}\." }
                    if ($match) {
                        $action = $Items[$match]
                        [Console]::CursorVisible = $prevCursor
                        Clear-Host
                        if ($action -is [scriptblock]) { & $action }
                        return
                    }
                }
                # Any other key: ignore (but could beep if desired)
            }
        }
    } while ($true)
}
