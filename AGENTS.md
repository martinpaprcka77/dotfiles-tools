# AGENTS.md — dotfiles-tools

> **For AI agents (Claude, DeepSeek, GPT-4, Reasonix, Copilot):**  
> This file tells you everything you need to know to work with this repo.

---

## What this repo is

**dotfiles-tools** — the **interactive toolbox** half of the PowerShell Dotfiles Ecosystem.

| Attribute | Value |
|-----------|-------|
| **Location on disk** | `~/Projects/tools/` |
| **Companion repo** | [dotfiles-powershell](https://github.com/martinpaprcka77/dotfiles-powershell) (`~/.config/powershell/`) |
| **Portal** | [martinpaprcka77.github.io](https://martinpaprcka77.github.io) |
| **Language** | PowerShell 5.1 / 7+ |
| **Module** | `Toolkit` — 18 exported functions |
| **Tests** | 25+ Pester cases in `tests/Toolkit.Tests.ps1` |
| **Dependencies** | dotfiles-powershell (provides `$env:DOTFILES_TOOLS`), Git, Docker (optional) |

---

## Directory map (what each file does)

```
~/Projects/tools/
├── .gitignore
├── README.md                ← GitHub README with 2 Mermaid UML diagrams
├── index.html               ← GitHub Pages landing page
├── AGENTS.md                ← this file
├── CLAUDE.md                ← Claude memory file
│
├── bin/                     ← in PATH (accessible from anywhere)
│   ├── menu.ps1             ← Import-Module Toolkit → Start-MainMenu
│   └── check.ps1            ← Import-Module Toolkit → Invoke-SystemCheck
│
├── lib/                     ← source functions (dot-sourced by Toolkit.psm1)
│   ├── common.ps1           ← Test-Admin, Write-Info/Success/Warn/Err, Confirm-Action
│   ├── menu.ps1             ← Show-Menu — generic numbered menu engine
│   ├── checkers.ps1         ← Get-DiskStatus, Get-ServiceStatus, Get-NetworkInfo, Get-TopProcesses, Invoke-SystemCheck
│   └── config.ps1           ← Get-ToolkitConfig (defaults→JSON→env merge), Save-ToolkitConfig, Merge-Hashtable
│
├── Toolkit/                 ← PowerShell module
│   ├── Toolkit.psd1         ← manifest — 18 FunctionsToExport
│   └── Toolkit.psm1         ← dot-sources all lib/*.ps1, Export-ModuleMember
│
├── menu/                    ← standalone scripts (can run directly or via module)
│   ├── menu-main.ps1        ← Start-MainMenu — Docker, System, Git, Tools, Exit
│   ├── menu-docker.ps1      ← Show-DockerMenu — ps, images, stats, system df, logs
│   └── menu-git.ps1         ← Show-GitMenu — status, log, branch, remote, stash, commit
│
├── scripts/
│   ├── Add-WTProfiles.ps1   ← Windows Terminal setup (4 profiles, WhatIf, BOM-free save)
│   ├── Generate-Icons.ps1   ← PNG icon generator (System.Drawing, 32×32)
│   ├── configure.ps1        ← interactive config wizard (5 steps)
│   └── setup-repos.ps1      ← Git+GitHub automation (gh repo create + push)
│
├── configs/settings.json    ← default config (theme, docker, system checks)
├── tests/Toolkit.Tests.ps1  ← Pester tests (6 contexts, 25+ cases, Mock coverage)
├── icons/README.md          ← instructions to run Generate-Icons.ps1
│
└── docs/
    ├── ARCHITECTURE.md       ← 6 Mermaid UML diagrams
    ├── MANUAL.md             ← 11-section user guide
    ├── ROADMAP.md            ← 5 phases, known issues, contribution guide
    └── PROMPT.md             ← original AI prompt
```

---

## How it works (dependency chain)

```
bin/menu.ps1 ──→ Import-Module Toolkit/Toolkit.psd1 ──→ Toolkit.psm1 ──→ dot-source lib/*.ps1
bin/check.ps1 ──→ Import-Module Toolkit/Toolkit.psd1 ──→ Toolkit.psm1 ──→ dot-source lib/*.ps1

menu/menu-main.ps1 ──→ Import-Module Toolkit ──→ Start-MainMenu
menu/menu-docker.ps1 ──→ Import-Module Toolkit ──→ Show-DockerMenu
menu/menu-git.ps1 ──→ Import-Module Toolkit ──→ Show-GitMenu
```

---

## How to add a new feature

1. **New utility function** → add to `lib/common.ps1`
2. **New diagnostic check** → add to `lib/checkers.ps1`
3. **New menu item** → add a scriptblock to `menu/menu-main.ps1`
4. **New submenu** → create `menu/menu-whatever.ps1`, export function from Toolkit
5. **After adding** → update:
   - `Toolkit.psm1`: add to `Export-ModuleMember` list
   - `Toolkit.psd1`: add to `FunctionsToExport` array
   - `tests/Toolkit.Tests.ps1`: add test case
   - Update `MANUAL.md` and `README.md` function tables

---

## How to run tests

```powershell
Install-Module Pester -Force
Invoke-Pester ~/Projects/tools/tests/Toolkit.Tests.ps1
```

---

## Coding conventions

- **Comment-based help** on every function (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`)
- **Verb-Noun naming** (`Get-DiskStatus`, `Invoke-SystemCheck`, `Show-Menu`)
- **Menu scripts**: standalone runnable + export as module function
- **Error handling**: `try/catch` for external commands, graceful degradation (e.g., Docker not installed → warn, don't crash)
- **Config**: merge defaults → JSON file → env vars (`$env:TOOLKIT_*`)
- **Cross-platform**: `$IsWindows` guard on Windows Terminal & System.Drawing scripts
- **Mock-friendly**: menus use `Show-Menu` engine (mockable), checkers use `Get-CimInstance` (mockable)

---

## Toolk module — 18 exported functions

| Category | Functions |
|----------|-----------|
| Menu | `Start-MainMenu`, `Show-DockerMenu`, `Show-GitMenu`, `Show-Menu` |
| Diagnostics | `Invoke-SystemCheck`, `Get-DiskStatus`, `Get-ServiceStatus`, `Get-NetworkInfo`, `Get-TopProcesses` |
| Utility | `Test-Admin`, `Get-ScriptDirectory`, `Confirm-Action` |
| Logging | `Write-Info`, `Write-Success`, `Write-Warn`, `Write-Err` |
| Config | `Get-ToolkitConfig`, `Save-ToolkitConfig`, `Merge-Hashtable` |

---

## Prompts that understand this project

The original prompt that generated this entire ecosystem is preserved at:
- [docs/PROMPT.md](docs/PROMPT.md)
- [Gist: prompt-reference](https://gist.github.com/martinpaprcka77/d4126cd2ef53a97a6a6beb38d420bff6)

---

## Related resources

| Resource | URL |
|----------|-----|
| **Portal** | https://martinpaprcka77.github.io |
| **Companion repo** | https://github.com/martinpaprcka77/dotfiles-powershell |
| **Gist: Install** | https://gist.github.com/martinpaprcka77/bafc2457fd9d93daf1b1b69c348e0cfd |
| **Gist: Cheatsheet** | https://gist.github.com/martinpaprcka77/b30ae161dfb693431a438e309f236467 |
| **Gist: Prompt** | https://gist.github.com/martinpaprcka77/d4126cd2ef53a97a6a6beb38d420bff6 |
