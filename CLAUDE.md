# CLAUDE.md — dotfiles-tools

> Memory file for Claude. Load this before working with the repo.

## Identity
This is the **interactive toolbox** repo of the PowerShell Dotfiles Ecosystem.
Companion: `dotfiles-powershell` at `~/.config/powershell/`.

## Key files
- `bin/menu.ps1`, `bin/check.ps1` — entry points (in PATH)
- `Toolkit/Toolkit.psm1` + `Toolkit.psd1` — module (18 functions)
- `lib/menu.ps1` — generic `Show-Menu` engine (numbered, extensible)
- `lib/checkers.ps1` — `Invoke-SystemCheck` + 4 sub-checks
- `lib/config.ps1` — 3-layer config merge (defaults→JSON→env)
- `scripts/configure.ps1` — 5-step interactive wizard
- `scripts/setup-repos.ps1` — GitHub repo automation (gh + git)
- `scripts/Add-WTProfiles.ps1` — Windows Terminal profile injection

## Module structure
```
bin/*.ps1 → Import-Module Toolkit → Toolkit.psd1 → Toolkit.psm1 → dot-source lib/*.ps1
```
To add a function: write it in `lib/`, add to `Export-ModuleMember` in `.psm1`, add to `FunctionsToExport` in `.psd1`.

## How to run
- After install: `menu` or `check` from anywhere
- Direct: `Import-Module ~/Projects/tools/Toolkit/Toolkit.psd1`
- Tests: `Invoke-Pester ~/Projects/tools/tests/Toolkit.Tests.ps1` (25+ cases)

## Architecture decisions
- Separate `bin/` (PATH) vs `menu/` (runnable directly or via module)
- `Show-Menu` engine is generic — all menus reuse it (Don't Repeat Yourself)
- Config: defaults → `settings.json` → `$env:TOOLKIT_*` (least to most specific)
- Platform guards: `$IsWindows` on `Add-WTProfiles.ps1` and `Generate-Icons.ps1`

## Doc links
- [AGENTS.md](AGENTS.md) — full AI agent guide
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — 6 Mermaid UML diagrams
- [docs/MANUAL.md](docs/MANUAL.md) — 11-section user guide
- [docs/ROADMAP.md](docs/ROADMAP.md) — 5 phases, known issues
- [docs/PROMPT.md](docs/PROMPT.md) — original AI prompt
