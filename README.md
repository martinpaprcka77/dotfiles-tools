# dotfiles-tools

**Osobní PowerShell toolbox** — menu, diagnostika, správa Dockeru a Git přes interaktivní rozhraní.

## Adresářová struktura

```
~/Projects/tools/
├── bin/                         ← v PATH (spustitelné odkudkoliv)
│   ├── menu.ps1                  ← hlavní menu
│   ├── check.ps1                 ← systémová diagnostika
├── lib/                         ← zdrojové funkce
│   ├── common.ps1               ← Test-Admin, Write-Info, …
│   ├── menu.ps1                 ← Show-Menu (generické menu)
│   └── checkers.ps1             ← diagnostika (disky, služby, síť)
├── Toolkit/                     ← PowerShell modul
│   ├── Toolkit.psm1             ← dot-sourcuje lib/, exportuje
│   └── Toolkit.psd1             ← manifest modulu
├── menu/                        ← samostatné menu skripty
│   ├── menu-main.ps1            ← Start-MainMenu
│   ├── menu-docker.ps1          ← Show-DockerMenu
│   └── menu-git.ps1             ← Show-GitMenu
├── scripts/
│   ├── Add-WTProfiles.ps1       ← konfiguruje Windows Terminal
│   ├── Generate-Icons.ps1       ← generuje PNG ikony
│   ├── setup-repos.ps1           ← automatizuje Git+GitHub
│   └── profiles-fragment.json   ← vygenerovaný fragment
├── docs/
│   ├── ARCHITECTURE.md
│   ├── MANUAL.md
│   ├── ROADMAP.md
│   └── PROMPT.md
├── configs/settings.json        ← výchozí nastavení
├── icons/                       ← ikony pro WT (vygenerovat)
├── tests/Toolkit.Tests.ps1      ← Pester testy
```

## Rychlé použití

```powershell
# Hlavní menu (po instalaci a přidání bin/ do PATH)
menu

# Systémová diagnostika
check

# Nebo přímo
Import-Module ~/Projects/tools/Toolkit/Toolkit.psd1
Start-MainMenu
Invoke-SystemCheck
```

## Hlavní menu

```
  HLAVNÍ MENU
  ------------
  1  Docker menu
  2  Systémová diagnostika
  3  Git menu
  4  Nástroje
  5  Konec

  Volba: _
```

## Modul Toolkit

Exportuje 15 veřejných funkcí:

| Kategorie | Funkce |
|-----------|--------|
| **Menu** | `Start-MainMenu`, `Show-DockerMenu`, `Show-GitMenu`, `Show-Menu` |
| **Diagnostika** | `Invoke-SystemCheck`, `Get-DiskStatus`, `Get-ServiceStatus`, `Get-NetworkInfo`, `Get-TopProcesses` |
| **Utility** | `Test-Admin`, `Get-ScriptDirectory`, `Confirm-Action` |
| **Logging** | `Write-Info`, `Write-Success`, `Write-Warn`, `Write-Err` |

## Instalace

Viz [instalační průvodce](../.config/powershell/README.md#instalace) v dotfiles-powershell.

## Dokumentace

| Dokument | Popis |
|----------|-------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Diagramy komponent a datových toků |
| [MANUAL.md](docs/MANUAL.md) | Kompletní uživatelský manuál |
| [ROADMAP.md](docs/ROADMAP.md) | Plánované funkce |
| [PROMPT.md](docs/PROMPT.md) | Původní AI prompt |
