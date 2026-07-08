<#
.SYNOPSIS
    Logika interaktivního menu.
.DESCRIPTION
    Funkce pro vykreslování a obsluhu číselného menu v konzoli.
.NOTES
    Cesta: ~/Projects/tools/lib/menu.ps1
#>

<#
.SYNOPSIS
    Zobrazí číselné menu a vrátí volbu uživatele.
.DESCRIPTION
    Vykreslí položky menu, přečte vstup a validuje jej.
.PARAMETER Title
    Nadpis menu.
.PARAMETER Items
    Hashtable s položkami (klíč = label, hodnota = scriptblock).
.EXAMPLE
    Show-Menu -Title "Hlavní menu" -Items @{
        "1. Docker" = { Show-DockerMenu }
        "2. Konec"  = { return }
    }
#>
function Show-Menu {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [hashtable]$Items
    )

    do {
        Clear-Host
        Write-Host "`n  $Title`n" -ForegroundColor Cyan
        Write-Host "  " + ("-" * ($Title.Length + 2)) -ForegroundColor DarkGray

        foreach ($key in $Items.Keys | Sort-Object) {
            Write-Host "  $key" -ForegroundColor White
        }

        $choice = Read-Host "`n  Volba"

        if ($Items.ContainsKey($choice)) {
            $action = $Items[$choice]
            if ($action -is [scriptblock]) {
                & $action
            }
        }
        elseif ($choice -eq '0' -or $choice -eq 'q') {
            break
        }
        else {
            Write-Warn "Neplatná volba: $choice"
            Start-Sleep -Milliseconds 800
        }
    } while ($true)
}
