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
| **Module** | `Toolkit` — 36 exported functions |
| **Tests** | 63 Pester cases in `tests/Toolkit.Tests.ps1` |
| **Dependencies** | Git, Docker (optional); dotfiles-powershell is optional too — it sets `$env:DOTFILES_TOOLS` as a convenience, but every self-referential lookup (`scripts/*.ps1`, `.vscode/`) falls back to deriving this repo's own root from `$PSScriptRoot` when it's unset |

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
│   ├── menu.ps1             ← Show-Menu — arrow-key menu engine with live status column;
│   │                           box width clamped to [Console]::WindowWidth, Desc/Detector text
│   │                           truncated to fit (a long detector message otherwise wraps the
│   │                           line and breaks the border — field-reported)
│   ├── checkers.ps1         ← Get-DiskStatus, Get-ServiceStatus, Get-NetworkInfo, Get-TopProcesses, Invoke-SystemCheck
│   ├── config.ps1           ← Get-ToolkitConfig (defaults→JSON→env merge), Save-ToolkitConfig, Merge-Hashtable
│   ├── modulepath.ps1       ← Get/Add/Remove/Reset/Export/Import/Test-PSModulePath (7 functions)
│   └── detectors.ps1        ← Show-Menu live-status detectors + Invoke-IfAvailable guard
│
├── Toolkit/                 ← PowerShell module
│   ├── Toolkit.psd1         ← manifest — 36 FunctionsToExport
│   └── Toolkit.psm1         ← dot-sources all lib/*.ps1 and menu/menu-*.ps1, Export-ModuleMember
│
├── menu/                    ← standalone scripts (can run directly or via module)
│   ├── menu-main.ps1        ← Start-MainMenu — Status, Dotfiles, System, Docker, Git, Terminal, PowerShell, VS Code, Exit
│   ├── menu-docker.ps1      ← Show-DockerMenu — ps, images, stats, system df, logs
│   ├── menu-git.ps1         ← Show-GitMenu — status, log, branch, remote, stash, commit
│   ├── menu-terminal.ps1    ← Show-TerminalMenu — WT profiles, schemes, fonts, shell integration
│   ├── menu-dotfiles.ps1    ← Show-DotfilesMenu — install, update, backup, restore, configure, modernize, windows
│   ├── menu-pwsh.ps1        ← Show-PwshMenu — edit/reload profile, performance, modules, modulepath
│   └── menu-vscode.ps1      ← Show-VSCodeMenu — settings, tasks, agent, backup
│
├── scripts/
│   ├── Add-WTProfiles.ps1   ← Windows Terminal JSON fragment generator (WhatIf, BOM-free save, WSL auto-detect)
│   ├── Generate-Icons.ps1   ← PNG icon generator (System.Drawing, 32×32)
│   ├── configure.ps1        ← interactive config wizard (5 steps)
│   ├── setup-repos.ps1      ← Git+GitHub automation (gh repo create + push)
│   ├── deps.ps1             ← winget dependency installer
│   ├── windows.ps1          ← Windows defaults (Explorer, taskbar, privacy, bloatware)
│   ├── modernize.ps1        ← PSResourceGet migration, legacy module cleanup
│   └── precheck.ps1         ← read-only pre-install inventory (30+ checks)
│
├── configs/
│   ├── settings.json        ← default config (theme, docker, system checks)
│   └── wt-schemes.json      ← WT color schemes — single source of truth, read by Add-WTProfiles.ps1
├── tests/Toolkit.Tests.ps1  ← Pester tests (63 cases, Mock coverage)
├── icons/README.md          ← instructions to run Generate-Icons.ps1
├── .vscode/                 ← settings.json, tasks.json, agent-instructions.md
├── .github/workflows/       ← test.yml (Windows CI)
├── githooks/                ← post-checkout/post-merge reminders, install.sh
│
└── docs/
    ├── ARCHITECTURE.md       ← Mermaid UML diagrams
    ├── MANUAL.md             ← user guide
    ├── ROADMAP.md            ← phases, known issues, contribution guide
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

### New in 2026
- `deps.ps1` — winget-based dependency installer (Git, PS7, WT, VS Code, oh-my-posh, modules)
- `windows.ps1` — Windows defaults (Explorer, taskbar, privacy, bloatware)
- `Add-WTProfiles.ps1` — rewritten to generate JSON fragment extensions (WT 1.24+)
- `.vscode/settings.json` + `.vscode/tasks.json` — committed VS Code config (5 tasks)
- `lib/config.ps1` — 3-layer config (defaults → JSON → env), `configure.ps1` wizard

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
- **Watch for short-name collisions with PowerShell's own built-in aliases** (`Get-Command -CommandType Alias`)
  before picking a 2-4 letter function/alias name — a built-in ALIAS always wins over a same-named
  FUNCTION in command resolution, silently. This shipped as a real bug in the companion repo: `gcm`/`gps`
  git shortcuts (defined as functions) were shadowed by PowerShell's built-in `gcm`→`Get-Command` and
  `gps`→`Get-Process` aliases and never actually ran — no error, just silently wrong behavior. Fix pattern:
  `Remove-Item Alias:<name> -Force -ErrorAction SilentlyContinue` before defining the function, or use
  `Set-Alias -Force` (which correctly overrides, unlike a same-named function).
- **Never assume `$env:DOTFILES_TOOLS` is set** when locating a file inside this repo — it's set
  by the companion profile as a convenience, but this repo must work standalone (menu items can be
  launched directly, e.g. by a Windows Terminal custom profile, without the companion profile
  loaded). Use the fallback pattern from `lib/config.ps1`: `$toolsRoot = if ($env:DOTFILES_TOOLS)
  { $env:DOTFILES_TOOLS } else { Split-Path $PSScriptRoot -Parent }`. Field-reported crash:
  `Join-Path $env:DOTFILES_TOOLS 'scripts\...'` with a `$null` env var throws
  "Cannot bind argument to parameter 'Path' because it is null" — now fixed in
  `menu-terminal.ps1`/`menu-dotfiles.ps1`/`menu-vscode.ps1`.

---

## Toolkit module — 36 exported functions

| Category | Functions |
|----------|-----------|
| Menu | `Start-MainMenu`, `Show-DockerMenu`, `Show-GitMenu`, `Show-TerminalMenu`, `Show-DotfilesMenu`, `Show-PwshMenu`, `Show-VSCodeMenu`, `Show-Menu` |
| Diagnostics | `Invoke-SystemCheck`, `Get-DiskStatus`, `Get-ServiceStatus`, `Get-NetworkInfo`, `Get-TopProcesses` |
| Utility | `Test-Admin`, `Get-ScriptDirectory`, `Confirm-Action` |
| Logging | `Write-Info`, `Write-Success`, `Write-Warn`, `Write-Err` |
| Config | `Get-ToolkitConfig`, `Save-ToolkitConfig`, `Merge-Hashtable` |
| PSModulePath | `Get-PSModulePath`, `Add-PSModulePath`, `Remove-PSModulePath`, `Reset-PSModulePath`, `Export-PSModulePath`, `Import-PSModulePath`, `Test-PSModulePath` |
| Detectors | `Get-ModuleStackStatus`, `Test-LegacyPowerShellGetPresent`, `Test-PSResourceGetReady`, `Get-DotfilesCompanionStatus`, `Get-ModulePathStatus`, `Invoke-IfAvailable` |

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
