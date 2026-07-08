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

```mermaid
sequenceDiagram
    actor U as Uživatel
    participant WT as Add-WTProfiles.ps1
    participant FS as Souborový systém
    participant JSON as JSON parser

    U->>WT: .\Add-WTProfiles.ps1 [-WhatIf]
    WT->>FS: Najít settings.json
    alt nenalezen
        WT-->>U: Error: nenalezen
    else nalezen
        WT->>FS: Zálohovat do .backup.*.json
        WT->>FS: Přečíst raw obsah
        WT->>WT: Odstranit // komentáře
        WT->>JSON: Parsovat čisté JSON

        loop 4 profily (Menu, Projekty, PS7, PS5)
            WT->>FS: Test-Path ikona?
            alt ikona existuje
                WT->>WT: Nastavit icon cestu
            else neexistuje
                WT->>WT: icon = null
            end
            WT->>JSON: Přidat/aktualizovat profil
        end

        WT->>FS: Uložit bez BOM (UTF8Encoding)
        WT->>FS: Vygenerovat profiles-fragment.json
        WT-->>U: Hotovo!
    end
```

## Menu engine (Show-Menu)

```mermaid
flowchart TD
    START["Show-Menu -Title 'X' -Items @{...}"] --> CLEAR["Clear-Host"]
    CLEAR --> DRAW["Vykreslit nadpis a položky"]
    DRAW --> INPUT["Read-Host 'Volba'"]
    INPUT --> VALID{"Klíč existuje?"}
    VALID -->|ano| EXEC["Spustit scriptblock"]
    VALID -->|ne| CHECK{"'0' nebo 'q'?"}
    CHECK -->|ano| END["Konec"]
    CHECK -->|ne| WARN["Write-Warn<br/>Sleep 800ms"]
    EXEC --> CLEAR
    WARN --> CLEAR
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
│  FunctionsToExport: 30 functions         │
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

## GUID profilů Windows Terminal

| Profil | GUID | Příkaz |
|--------|------|--------|
| Menu | `{11111111-1111-1111-1111-111111111111}` | `pwsh.exe` → `menu-main.ps1` |
| Projekty | `{22222222-2222-2222-2222-222222222222}` | `pwsh.exe` → `~/Projects/work` |
| PowerShell 7 | `{33333333-3333-3333-3333-333333333333}` | `pwsh.exe` → `~` |
| WinPS 5.1 | `{44444444-4444-4444-4444-444444444444}` | `powershell.exe` → `~` |
