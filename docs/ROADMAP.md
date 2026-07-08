# Roadmap dotfiles-tools

Plánované funkce a směr vývoje. Priority: 🔴 vysoká · 🟡 střední · 🟢 nízká · ✅ hotovo

---

## Fáze 1: Základ (✅ hotovo)

- ✅ Modulární PowerShell profil (`dotfiles-powershell`)
- ✅ Idempotentní instalátor (`install.ps1` — WhatIf, Force, backup, summary)
- ✅ Update mechanism (`update.ps1` — git fetch + reload)
- ✅ Toolkit modul — **22 exportovaných funkcí**
- ✅ Interaktivní menu — 7 submenus (Dotfiles, Docker, Git, Terminal, PowerShell, VS Code, Diagnostika)
- ✅ Moderní menu engine — šipky ↑↓, zvýraznění, popisky, inline režim
- ✅ Arrow-key menu s popisky u každé položky
- ✅ CRUD operace na všech menu (Check, Backup, Restore, Reset, Clean)
- ✅ Systémová diagnostika (disky, služby, síť, procesy)
- ✅ Windows Terminal profily — JSON fragment extensions (WT 1.24+)
- ✅ 7 barevných schémat (One Half Dark, Dracula, Nord, TokyoNight, Catppuccin Mocha, Gruvbox Dark, Solarized Dark)
- ✅ WT shell integration (OSC 133 markery, showMarksOnScrollbar, autoMarkPrompts)
- ✅ Starship prompt (Rust) s `starship.toml` konfigurací (30+ modulů)
- ✅ oh-my-posh jako fallback
- ✅ Generování ikon (`Generate-Icons.ps1`)
- ✅ 25+ Pester testů (6 kontextů, Mock pokrytí)
- ✅ Bezpečné ukládání klíčů (`Get-SecretKey` — SecretManagement + env fallback)
- ✅ `extra.ps1` pattern — uživatelské přizpůsobení mimo Git
- ✅ AGENTS.md + CLAUDE.md v obou repozitářích
- ✅ GitHub Pages portal (`martinpaprcka77.github.io`)
- ✅ AI Prompts stránka — 8 modelů, 5 typů úloh
- ✅ 4 gisty (install, cheatsheet, prompt, master-prompt)

---

## Fáze 2: 2026 vylepšení (✅ hotovo)

- ✅ **Cascadia Code Nerd Font auto-installer** — `deps.ps1` stahuje a instaluje
- ✅ **`deps.ps1`** — winget auto-installer (Git, PS7, WT, VS Code, Starship, zoxide)
- ✅ **`windows.ps1`** — Windows defaults (Explorer, taskbar, privacy, bloatware)
- ✅ **WT JSON fragment** — nahrazuje staré editování settings.json
- ✅ **Shell integration** — OSC 133 markery, scrollbar marks, exit code coloring
- ✅ **VS Code integrace** — `.vscode/settings.json`, `tasks.json`, `agent-instructions.md`
- ✅ **`precheck.ps1`** — 30+ inventory kontrol před instalací
- ✅ **`configure.ps1`** — 5-step interaktivní wizard
- ✅ **`setup-repos.ps1`** — GitHub repo automatizace (gh + git)
- ✅ **zoxide** — smart directory jumper (náhrada za `z.ps1`)
- ✅ **wtprofile.ps1** — CTT-inspired Windows Terminal enhanced profile
- ✅ **core/perf.ps1** — Measure-Profile, Clear-PSCache, Optimize-ModuleLoading, Get-ProfileSize
- ✅ **core/status.ps1** — globální health dashboard (6 sekcí, 20+ kontrol)
- ✅ **core/extra.ps1.example** — šablona pro uživatelské přizpůsobení
- ✅ Konfigurační vrstva — `config.ps1` (defaults → JSON → $env:TOOLKIT_*)
- ✅ **7 barevných WT schémat** z windowsterminalthemes.dev

---

## Fáze 3: Rozšíření (🟡 plánováno)

- [ ] **Linux podpora** — otestovat cesty pro Linux (`~/.config/`, `/home/`)
- [ ] **macOS podpora** — otestovat s PowerShell 7 na macOS
- [ ] **Live dashboard** — real-time CPU/RAM/Disk monitoring
- [ ] **Síťová diagnostika** — `Test-NetConnection` na klíčové endpointy
- [ ] **Více Docker příkazů** — `docker compose`, network management
- [ ] **Transient prompt** — kolaps promptu po provedení příkazu (Starship)
- [ ] **PSResourceGet migration** — plný přechod z PowerShellGet
- [ ] **AddToHistoryHandler** — vlastní PSReadLine history filter

---

## Fáze 4: Integrace (🟢)

- [ ] **WSL profily** — automatická detekce ve WT fragmentu
- [ ] **Git hooks** — `post-checkout`, `post-merge` notifikace
- [ ] **CI/CD** — GitHub Actions pro Pester testy, validaci JSON
- [ ] **PowerShell Gallery** — publikovat Toolkit modul
- [ ] **Komunitní příspěvky** — šablona pro issues a pull requests

---

## Fáze 5: Ekosystém (🟢)

- [ ] **Web bootstrap** — `iex (iwr '...')` instalace bez Gitu
- [ ] **Instalační skript pro Windows** — kompletní setup z čisté instalace
- [ ] **Dokumentační web** — statický web generovaný z Markdown dokumentace

---

## Známé problémy

| Problém | Stav | Plán |
|---------|------|------|
| `Add-WTProfiles.ps1` vyžaduje Windows Terminal | ✅ Vyřešeno | `$IsWindows` guard |
| `Generate-Icons.ps1` vyžaduje .NET Framework | ✅ Vyřešeno | `$IsWindows` guard |
| `deps.ps1` + `windows.ps1` — Windows-only | ✅ Vyřešeno | Platform guardy |
| Cesty s diakritikou nejsou testovány | Netestováno | Přidat testy |
| PS5 nepodporuje `&&` a `||` | Omezení PS5 | Používat `;` nebo `if` |

---

## Jak přispět

1. Fork repozitáře
2. Vytvoř branch (`feature/muj-nastroj`)
3. Přidej testy do `tests/`
4. Aktualizuj `MANUAL.md` a `README.md`
5. Otevři Pull Request

Pravidla:
- Všechny skripty musí mít comment-based help
- Idempotentní operace kde to dává smysl
- Respektovat výkon profilu (žádné pomalé importy)
- Cross-platform guardy (`$IsWindows` / `$IsLinux`)
