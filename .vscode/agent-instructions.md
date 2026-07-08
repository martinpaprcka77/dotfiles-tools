# Agent Instructions — PowerShell Dotfiles Ecosystem

> Read by VS Code agents (Copilot, GPT-4, Claude) when `#codebase` is referenced.
> Keep this file up to date — it's the primary context the AI has about this project.

## What this project is

Two-repo PowerShell dotfiles ecosystem:
- **dotfiles-powershell** (`~/.config/powershell/`) — modular profile orchestration
- **dotfiles-tools** (`~/Projects/tools/`) — interactive toolbox (menus, diagnostics, Toolkit module)

Portal: https://martinpaprcka77.github.io

## Architecture

```
Profile load: $PROFILE → bootstrap → profile.ps1 → core/*.ps1 → ps7/ → hosts/
Menu system: bin/menu.ps1 → Toolkit.psd1 → Toolkit.psm1 → lib/*.ps1
Config: Get-ToolkitConfig (defaults → settings.json → $env:TOOLKIT_*)
```

## How to build / test

```powershell
# No build step — everything is interpreted PowerShell
# Test:
Invoke-Pester ~/Projects/tools/tests/Toolkit.Tests.ps1

# Reload profile:
. ~/.config/powershell/profile.ps1

# Pre-check inventory:
~/Projects/tools/scripts/precheck.ps1
```

## Key conventions

- **Comment-based help** on every function (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE)
- **Verb-Noun** naming for functions
- **try/catch** on external/network calls
- **$PSCmdlet.ShouldProcess** with WhatIf support on destructive scripts
- **$IsWindows / $IsLinux** guards on platform-specific code
- **Join-Path** for all path building, never string concatenation
- **Toolkit.psm1** exports must match **Toolkit.psd1** `FunctionsToExport`

## File roles

| File | Role |
|------|------|
| `profile.ps1` | Main orchestrator — dot-sources everything |
| `install.ps1` | Idempotent installer (WhatIf, Force, backups) |
| `update.ps1` | Git pull + profile reload |
| `lib/menu.ps1` | Show-Menu — arrow-key interactive menu engine |
| `lib/checkers.ps1` | Invoke-SystemCheck + disk/service/network/process checks |
| `lib/config.ps1` | Get-ToolkitConfig — 3-layer config merge |
| `scripts/Add-WTProfiles.ps1` | WT JSON fragment generator |
| `scripts/deps.ps1` | Winget + PSResourceGet dependency installer |
| `scripts/windows.ps1` | Windows defaults (Explorer, privacy, bloatware) |
| `scripts/precheck.ps1` | Pre-install inventory check (30+ checks) |
| `scripts/configure.ps1` | Interactive config wizard |
| `scripts/setup-repos.ps1` | GitHub repo automation |

## When adding a feature

1. Write function in `lib/` (for tools) or `core/` (for powershell)
2. Update `Toolkit.psm1` Export-ModuleMember + `Toolkit.psd1` FunctionsToExport
3. Add Pester test in `tests/Toolkit.Tests.ps1`
4. Update `MANUAL.md` and `README.md`
5. Run `Invoke-Pester` to verify

## When fixing a bug

1. Read the failing script and its dependencies
2. Check `precheck.ps1` output for environment mismatches
3. Run `install.ps1 -Force` to ensure bootstrap is current
4. Verify with `Invoke-Pester`
5. Update `docs/ROADMAP.md` known issues if the bug is a known limitation
