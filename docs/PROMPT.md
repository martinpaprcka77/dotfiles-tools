# Původní prompt

Tento soubor uchovává původní prompt, ze kterého byla vygenerována celá kódová základna. Slouží pro:
- **Reprodukovatelnost** — stejný prompt lze poslat jinému modelu a získat podobný výsledek.
- **Dokumentaci záměru** — zachycuje kompletní specifikaci v jednom souboru.
- **Iteraci** — při úpravách je vidět, co se změnilo oproti původnímu zadání.

---

```
Jsi expert na PowerShell, správu dotfiles a Windows Terminal. 
Vytvoř **kompletní a spustitelný** projekt, který realizuje následující zadání. 
Generuj všechny soubory jako samostatné kódové bloky s uvedenou relativní cestou 
od uživatelského adresáře (%USERPROFILE% resp. $HOME). Struktura musí být připravena 
k okamžitému použití po naklonování do dvou Git repozitářů.

## 1. Cíl
Vytvořit osobní PowerShell ekosystém, který:
- obchází OneDrive (profily i moduly),
- je plně verzovaný (Git),
- přenositelný mezi stroji (Windows, částečně Linux),
- obsahuje modulární profil, nástrojový toolbox a automatické nastavení Windows Terminálu.

## 2. Výsledné repozitáře
A) **dotfiles-powershell** - umístění: `~/.config/powershell/`
B) **dotfiles-tools** - umístění: `~/Projects/tools/`

## 3. Detailní požadavky

### A) dotfiles-powershell
- `profile.ps1`: hlavní skript, který detekuje verzi PS (5/7) a hostitele (ConsoleHost, VSCode) a dot-sourcuje:
  - všechny `.ps1` z `core/`
  - verzi specifický profil (`ps5/profile.ps1` nebo `ps7/profile.ps1`)
  - hostitelský profil z `hosts/` (pokud existuje)
  - nastaví `$env:DOTFILES_PWSH` a `$env:DOTFILES_TOOLS` na správné cesty
  - pro PS7 opraví `PSModulePath`, aby moduly nepadaly do OneDrive (přidá `%LOCALAPPDATA%\PowerShell\Modules` na začátek)
  - volitelně zobrazí dobu načtení, pokud `$env:PROFILE_BENCHMARK` je `$true`
- `install.ps1`: idempotentní instalační skript, který:
  - naklonuje/aktualizuje repozitáře `dotfiles-powershell` a `dotfiles-tools` (URL jsou placeholder)
  - vloží bootstrap do všech známých profilových souborů
  - nastaví uživatelskou proměnnou `PATH` (trvale) tak, aby obsahovala `%USERPROFILE%\Projects\tools\bin`
  - nabídne spuštění `scripts\Add-WTProfiles.ps1` pro nastavení Windows Terminálu
- `core/aliases.ps1`: příklady aliasů (např. `Set-Alias ll Get-ChildItem`)
- `core/functions.ps1`: užitečné funkce (např. `Edit-Profile`, `Reload-Profile`, `Get-SecretKey`)
- `core/env.ps1`: nastaví `$env:EDITOR`, přidá `~/Projects/tools/bin` do PATH
- `ps5/profile.ps1`: specifické nastavení pro Windows PowerShell 5.1
- `ps7/profile.ps1`: moderní PS7 nastavení - `PSReadLine`, `Terminal-Icons`, `oh-my-posh`
- `hosts/ConsoleHost.ps1`: specifické pro klasickou konzoli
- `hosts/VSCode.ps1`: pro integrovaný terminál VS Code

### B) dotfiles-tools
- `bin/`: spustitelné skripty přidané do PATH (`menu.ps1`, `check.ps1`)
- `lib/`: zdrojové funkce (`common.ps1`, `menu.ps1`, `checkers.ps1`)
- `Toolkit/`: PowerShell modul (`Toolkit.psm1`, `Toolkit.psd1`)
- `menu/`: interaktivní menu (`menu-main.ps1`, `menu-docker.ps1`, `menu-git.ps1`)
- `scripts/`: `Add-WTProfiles.ps1` (4 profily s GUID, WhatIf, BOM-free), `Generate-Icons.ps1` (System.Drawing)
- `configs/`: `settings.json`
- `tests/`: Pester testy
- `.gitignore`: ignorovat `*.secret`, `.env`

### C) Integrace s bezpečností
- API klíče přes `Microsoft.PowerShell.SecretManagement`
- Funkce `Get-SecretKey` vrací klíč z trezoru nebo `$env:VAR`
- `.gitignore` zamezí commitnutí citlivých souborů

### D) Další vlastnosti
- Idempotentní instalace
- Podpora pro `-WhatIf` v `Add-WTProfiles.ps1`
- Všechny skripty s comment-based help
- Čistý kód s ošetřením chyb
- Výkonová doporučení (líné importy, žádné síťové operace v profilu)

## 4. Výstup
Vygeneruj **všechny soubory** jako bloky kódu s hlavičkou `# Cesta: <relativní cesta>` a obsahem. 
Začni adresářovou strukturou (jako strom).
```
