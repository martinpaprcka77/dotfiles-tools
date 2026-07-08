# Roadmap dotfiles-tools

Plánované funkce a směr vývoje. Priority: 🔴 vysoká · 🟡 střední · 🟢 nízká · ✅ hotovo

---

## Fáze 1: Základ (✅ hotovo)

- ✅ Modulární PowerShell profil (`dotfiles-powershell`)
- ✅ Idempotentní instalátor (`install.ps1`)
- ✅ Toolkit modul (15 funkcí)
- ✅ Interaktivní menu (hlavní, Docker, Git)
- ✅ Systémová diagnostika (disky, služby, síť, procesy)
- ✅ Windows Terminal profily (`Add-WTProfiles.ps1`)
- ✅ Generování ikon (`Generate-Icons.ps1`)
- ✅ Pester testy
- ✅ Bezpečné ukládání klíčů (`Get-SecretKey`)

---

## Fáze 2: Nástroje (🟡 plánováno)

- [ ] **Uživatelské nástroje** — místo pro vlastní skripty v `bin/`
- [ ] Rozšíření menu o nové položky

---

## Fáze 3: Rozšíření (🟡)

- [ ] **Linux podpora** — otestovat a opravit cesty pro Linux (`~/.config/`, `/home/`, `:` místo `;`)
- [ ] **macOS podpora** — otestovat s PowerShell 7 na macOS
- [ ] **Konfigurační wizard** — interaktivní prvotní nastavení (výběr modulů, téma)
- [ ] **Záložní systém** — periodické zálohování `settings.json`, profilů
- [ ] **Health check při startu** — `core/health.ps1` — kontrola dostupnosti Git, Docker, důležitých cest
- [ ] **Více Docker příkazů** — `docker compose` operace, čištění (`prune`)
- [ ] **Síťová diagnostika** — `Test-NetConnection` na klíčové endpointy
- [ ] **Monitoring prostředků** — live dashboard CPU/RAM/Disk v terminálu

---

## Fáze 4: Integrace (🟢)

- [ ] **VS Code extension** — nastavení VS Code tasks pro spouštění menu položek
- [ ] **Windows Terminal fragment** — automatická registrace `profiles-fragment.json`
- [ ] **WSL integrace** — detekce WSL a odpovídající profily
- [ ] **Oh-my-posh téma** — vlastní téma v `~/.config/powershell/theme.json`
- [ ] **Git hooks** — `post-checkout`, `post-merge` notifikace v terminálu

---

## Fáze 5: Ekosystém (🟢)

- [ ] **Instalační skript pro Windows** — `.bat` / `.ps1` který provede kompletní setup z čisté instalace
- [ ] **CI/CD** — GitHub Actions pro Pester testy, validaci JSON, lint
- [ ] **Galerie** — publikovat Toolkit na PowerShell Gallery
- [ ] **Komunitní příspěvky** — šablona pro issues a pull requests
- [ ] **Dokumentační web** — statický web generovaný z Markdown dokumentace

---

## Známé problémy

| Problém | Stav | Plán |
|---------|------|------|
| `Add-WTProfiles.ps1` nefunguje bez Windows Terminal | Známé omezení | Detekce a přeskočení |
| `Generate-Icons.ps1` vyžaduje .NET Framework | Známé omezení | Fallback na `[System.Drawing.Common]` NuGet |
| Cesty s diakritikou nejsou testovány | Netestováno | Přidat testy |
| PS5 nepodporuje `&&` a `||` | Omezení PS5 | Používat `;` nebo `if` |

---

## Jak přispět

1. Fork repozitáře
2. Vytvoř branch (`feature/muj-nastroj`)
3. Přidej testy do `tests/`
4. Aktualizuj `MANUAL.md`
5. Otevři Pull Request

Pravidla:
- Všechny skripty musí mít comment-based help
- Idempotentní operace kde to dává smysl
- Respektovat výkon profilu (žádné pomalé importy)
