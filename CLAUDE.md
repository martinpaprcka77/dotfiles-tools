# CLAUDE.md — dotfiles-tools

> Memory file for Claude. Load this before working with the repo.

## Identity
This is the **interactive toolbox** repo of the PowerShell Dotfiles Ecosystem.
Companion: `dotfiles-powershell` at `~/.config/powershell/`.

## Key files
- `bin/menu.ps1`, `bin/check.ps1` — entry points (in PATH)
- `Toolkit/Toolkit.psm1` + `Toolkit.psd1` — module (36 functions)
- `lib/menu.ps1` — `Show-Menu` engine (arrow-key nav, extensible, live status column via `Detector`)
- `lib/detectors.ps1` — Show-Menu status detectors + `Invoke-IfAvailable` guard
- `lib/checkers.ps1` — `Invoke-SystemCheck` + 4 sub-checks (Windows-only, guarded)
- `lib/config.ps1` — 3-layer config merge (defaults→JSON→env)
- `lib/modulepath.ps1` — PSModulePath manager (7 functions)
- `scripts/configure.ps1` — 5-step interactive wizard
- `scripts/setup-repos.ps1` — GitHub repo automation (gh + git)
- `scripts/Add-WTProfiles.ps1` — Windows Terminal JSON fragment generator
- `scripts/modernize.ps1` — PSResourceGet migration, shares predicates with `lib/detectors.ps1`

## Module structure
```
bin/*.ps1 → Import-Module Toolkit → Toolkit.psd1 → Toolkit.psm1 → dot-source lib/*.ps1
```
To add a function: write it in `lib/`, add to `Export-ModuleMember` in `.psm1`, add to `FunctionsToExport` in `.psd1`.

## How to run
- After install: `menu` or `check` from anywhere
- Direct: `Import-Module ~/Projects/tools/Toolkit/Toolkit.psd1`
- Tests: `Invoke-Pester ~/Projects/tools/tests/Toolkit.Tests.ps1` (63 cases)

## Architecture decisions
- Separate `bin/` (PATH) vs `menu/` (runnable directly or via module)
- `Show-Menu` engine is generic — all menus reuse it (Don't Repeat Yourself)
- Config: defaults → `settings.json` → `$env:TOOLKIT_*` (least to most specific)
- Platform guards: `$IsWindows`-style checks on `Add-WTProfiles.ps1`, `Generate-Icons.ps1`,
  `windows.ps1`, `deps.ps1`, and `lib/checkers.ps1`/`lib/common.ps1`
- Menu items calling companion-repo functions (Show-Status, Measure-Profile, …) go through
  `Invoke-IfAvailable` — this repo can be loaded standalone without the companion profile
- Before naming a short function/alias: check `Get-Command -CommandType Alias` first — a
  built-in alias silently wins over a same-named function (bit `gcm`/`gps` once, see AGENTS.md)

## Doc links
- [AGENTS.md](AGENTS.md) — full AI agent guide
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — 6 Mermaid UML diagrams
- [docs/MANUAL.md](docs/MANUAL.md) — 11-section user guide
- [docs/ROADMAP.md](docs/ROADMAP.md) — 5 phases, known issues
- [docs/PROMPT.md](docs/PROMPT.md) — original AI prompt
