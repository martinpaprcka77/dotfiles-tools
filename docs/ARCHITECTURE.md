# Architektura dotfiles-tools

## Komponentový diagram

```mermaid
graph TB
    subgraph "PATH (bin/)"
        MM["menu.ps1<br/>→ Start-MainMenu"]
        CHKD["check.ps1<br/>→ Invoke-SystemCheck"]
    end

    subgraph "Toolkit Module"
        PSM1["Toolkit.psm1<br/>(dot-sources lib/)"]
        PSD1["Toolkit.psd1<br/>(manifest)"]
    end

    subgraph "lib/ (source functions)"
        COMMON["common.ps1<br/>Test-Admin, Write-*, …"]
        MENU["menu.ps1<br/>Show-Menu engine"]
        CHECKERS["checkers.ps1<br/>Get-DiskStatus, …"]
    end

    subgraph "menu/ (standalone scripts)"
        MAIN["menu-main.ps1<br/>Start-MainMenu"]
        DOCKER["menu-docker.ps1<br/>Show-DockerMenu"]
        GIT_M["menu-git.ps1<br/>Show-GitMenu"]
    end

    subgraph "scripts/"
        WT["Add-WTProfiles.ps1<br/>Windows Terminal setup"]
        ICONS["Generate-Icons.ps1<br/>PNG generator"]
    end

    subgraph "External"
        WT_JSON["settings.json<br/>(Windows Terminal)"]
        SECRETS["SecretManagement<br/>vault"]
    end

    MM -->|"Import-Module"| PSD1
    CHKD -->|"Import-Module"| PSD1
    PSD1 --> PSM1
    PSM1 -->|"dot-source"| COMMON
    PSM1 -->|"dot-source"| MENU
    PSM1 -->|"dot-source"| CHECKERS
    MAIN -->|"Import-Module"| PSD1
    DOCKER -->|"Import-Module"| PSD1
    GIT_M -->|"Import-Module"| PSD1
    WT -->|"čte/zapisuje"| WT_JSON
    CHECKERS -->|"Get-SecretKey (volitelné)"| SECRETS
```

## Datový tok: Add-WTProfiles.ps1

Reálná implementace **negeneruje settings.json editaci ani neodstraňuje `//` komentáře** — to
byl starší návrh. Od WT 1.24+ se používá **JSON fragment extension**
(`%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json`), kterou WT čte
automaticky bez zásahu do uživatelova `settings.json`. Profily se párují podle `name`, ne GUID —
žádné GUID se nikde negenerují ani nepoužívají.

```mermaid
sequenceDiagram
    actor U as Uživatel
    participant WT as Add-WTProfiles.ps1
    participant FS as Souborový systém

    U->>WT: .\Add-WTProfiles.ps1 [-WhatIf] [-Force]
    WT->>FS: Existuje fragment a není -Force?
    alt existuje, bez -Force
        WT-->>U: Skip — použij -Force
    else pokračuje
        WT->>WT: Detekce WSL distribucí (wsl -l -q)
        WT->>WT: Sestavit profily: Menu, Projekty (shell integration),<br/>PowerShell 7, WinPS 5.1 (bez shell-integration overrides —<br/>tyto dva jen aktualizují existující vestavěné profily jménem)
        WT->>FS: Načíst configs/wt-schemes.json (single source of truth)
        WT->>FS: Zálohovat existující fragment (.backup.<timestamp>)
        WT->>FS: Zapsat fragment bez BOM (UTF8Encoding)
        WT-->>U: Hotovo — restart WT pro projevení
    end
```

## Menu engine (Show-Menu)

Skutečná implementace používá **arrow-key navigaci přes `[Console]::ReadKey`**, ne číslované
`Read-Host` vstupy (číselné zkratky fungují taky, jako doplněk). Každá položka může nést
volitelný `Detector` scriptblock, který se vyhodnotí znovu při každém překreslení a zobrazí
živý stavový sloupec (✅/⚠️/❌ + text) vedle popisu.

```mermaid
flowchart TD
    START["Show-Menu -Title 'X' -Items @{...}"] --> NORM["Normalizovat položky<br/>(Action, Desc, Detector)"]
    NORM --> LOOP["Render loop"]
    LOOP --> DET["Vyhodnotit Detector<br/>pro každou položku (try/catch)"]
    DET --> DRAW["Vykreslit box: nadpis, položky<br/>+ Desc + živý stavový sloupec"]
    DRAW --> KEY["[Console]::ReadKey"]
    KEY --> ARROWS{"↑/↓?"}
    ARROWS -->|ano| MOVE["Posunout výběr"] --> LOOP
    ARROWS -->|ne| ENTERQ{"Enter / číslo?"}
    ENTERQ -->|ano| EXEC["Spustit Action"]
    ENTERQ -->|ne| ESCQ{"Esc / q?"}
    ESCQ -->|ano| END["Konec"]
    ESCQ -->|ne| LOOP
    EXEC --> INLINE{"-Inline?"}
    INLINE -->|ano| LOOP
    INLINE -->|ne| END
```

## Hierarchie menu

```mermaid
graph LR
    MAIN["HLAVNÍ MENU<br/>Start-MainMenu"]
    DOCKER_M["DOCKER MENU<br/>Show-DockerMenu"]
    GIT_M["GIT MENU<br/>Show-GitMenu"]
    CHECK["DIAGNOSTIKA<br/>Invoke-SystemCheck"]
    TOOLS["NÁSTROJE<br/>(placeholder)"]

    MAIN -->|"1"| DOCKER_M
    MAIN -->|"2"| CHECK
    MAIN -->|"3"| GIT_M
    MAIN -->|"4"| TOOLS
    MAIN -->|"5"| EXIT["Konec"]

    DOCKER_M -->|"1"| DPS["docker ps -a"]
    DOCKER_M -->|"2"| DIM["docker images"]
    DOCKER_M -->|"3"| DST["docker stats"]
    DOCKER_M -->|"4"| DDF["docker system df"]
    DOCKER_M -->|"5"| DLO["docker logs"]
    DOCKER_M -->|"6"| BACK["Zpět"]

    GIT_M -->|"1"| GST["git status"]
    GIT_M -->|"2"| GLO["git log"]
    GIT_M -->|"3"| GBR["git branch -a"]
    GIT_M -->|"4"| GRM["git remote -v"]
    GIT_M -->|"5"| GSL["git stash list"]
    GIT_M -->|"6"| GCM["git commit -am"]
    GIT_M -->|"7"| BACK
```

## Vztah bin/ ↔ Toolkit ↔ lib/

```
bin/menu.ps1                  bin/check.ps1
    │                           │
    │ Import-Module             │ Import-Module
    ▼                           ▼
┌─────────────────────────────────────────┐
│           Toolkit.psd1 (manifest)       │
│  FunctionsToExport: 36 functions         │
└─────────────────────────────────────────┘
    │
    │ RootModule
    ▼
┌─────────────────────────────────────────┐
│           Toolkit.psm1 (module)         │
│  dot-sources all lib/*.ps1               │
│  Export-ModuleMember -Function @(...)    │
└─────────────────────────────────────────┘
    │
    │ dot-source
    ▼
┌────────────┐ ┌────────────┐ ┌──────────────┐
│ common.ps1 │ │ menu.ps1   │ │ checkers.ps1  │
└────────────┘ └────────────┘ └──────────────┘
```

## Profily Windows Terminal (fragment extension, párováno jménem)

Žádné GUID — WT fragment extensions párují profily podle `name`. `Menu`/`Projekty` jsou nové
vlastní profily (shell integration povolena). `PowerShell 7`/`Windows PowerShell 5.1` **aktualizují
existující vestavěné profily stejného jména** — záměrně jen o `icon`/`tabTitle`, nikdy o
font/colorScheme/shell-integration, aby se tiše nepřepsalo uživatelovo vlastní nastavení.

| Profil | Typ | Příkaz |
|--------|-----|--------|
| Menu | nový, vlastní | `pwsh.exe` → `menu-main.ps1` |
| Projekty | nový, vlastní | `pwsh.exe` → `~/Projects/work` |
| PowerShell 7 | update vestavěného | `pwsh.exe` → `~` |
| Windows PowerShell 5.1 | update vestavěného | `powershell.exe` → `~` |
| WSL: `<distro>` | auto-detekováno (`wsl -l -q`) | `wsl.exe -d <distro>` |
