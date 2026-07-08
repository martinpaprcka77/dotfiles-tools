<#
.SYNOPSIS
    Založí oba Git repozitáře na GitHubu a pushne obsah.
.DESCRIPTION
    Vytvoří repozitáře dotfiles-powershell a dotfiles-tools na GitHubu
    pomocí `gh` CLI, inicializuje git (pokud ještě není), commitne a pushne.
    Idempotentní — opakované spuštění je bezpečné.
.PARAMETER GitHubUser
    GitHub username nebo organizace (povinné).
.PARAMETER Visibility
    Viditelnost repozitářů: public nebo private (výchozí: public).
.PARAMETER DryRun
    Pouze zobrazí, co by se provedlo (WhatIf).
.EXAMPLE
    .\setup-repos.ps1 -GitHubUser "jan-novak"
    .\setup-repos.ps1 -GitHubUser "jan-novak" -Visibility private
    .\setup-repos.ps1 -GitHubUser "jan-novak" -DryRun
.NOTES
    Cesta: ~/Projects/tools/scripts/setup-repos.ps1
    Vyžaduje: Git, GitHub CLI (gh) přihlášený přes `gh auth login`
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$GitHubUser,

    [ValidateSet('public', 'private')]
    [string]$Visibility = 'public',

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

#region Validation
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git není nainstalován. Nainstaluj: winget install Git.Git"
    exit 1
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) není nainstalováno. Nainstaluj: winget install GitHub.cli"
    exit 2
}
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh není přihlášený. Spusť: gh auth login"
    exit 3
}
#endregion

#region Repo definitions
$repos = @(
    @{
        Name        = 'dotfiles-powershell'
        Path        = Join-Path $HOME '.config\powershell'
        Description = 'Modular PowerShell profile — bypasses OneDrive, version-controlled, portable'
        Topics      = @('powershell', 'dotfiles', 'profile', 'windows')
    },
    @{
        Name        = 'dotfiles-tools'
        Path        = Join-Path $HOME 'Projects\tools'
        Description = 'PowerShell toolbox — interactive menus, system diagnostics, Docker & Git helpers'
        Topics      = @('powershell', 'tools', 'menu', 'diagnostics', 'toolkit')
    }
)
#endregion

foreach ($repo in $repos) {
    Write-Host "`n=== $($repo.Name) ===" -ForegroundColor Cyan

    # Ensure directory exists
    if (-not (Test-Path $repo.Path)) {
        Write-Error "Adresář neexistuje: $($repo.Path). Nejprve rozbal/naklonuj projekt."
        continue
    }

    Push-Location $repo.Path

    try {
        #region Create GitHub repo
        $fullName = "$GitHubUser/$($repo.Name)"
        $repoExists = gh repo view $fullName 2>&1
        $repoAlreadyExists = ($LASTEXITCODE -eq 0)

        if (-not $repoAlreadyExists) {
            Write-Host "  Vytvářím repozitář: $fullName ($Visibility)..." -ForegroundColor Yellow
            if (-not $DryRun) {
                $topicArgs = $repo.Topics | ForEach-Object { '--add-topic', $_ }
                gh repo create $fullName --$Visibility --description $repo.Description @topicArgs
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Nepodařilo se vytvořit repozitář $fullName"
                    continue
                }
                Write-Host "  [+] Vytvořeno: https://github.com/$fullName" -ForegroundColor Green
            }
            else {
                Write-Host "  [DRY RUN] gh repo create $fullName --$Visibility" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Host "  [=] Repozitář již existuje: https://github.com/$fullName" -ForegroundColor Gray
        }
        #endregion

        #region Initialize Git (if not already)
        if (-not (Test-Path '.git')) {
            Write-Host "  Inicializuji Git..." -ForegroundColor Yellow
            if (-not $DryRun) {
                git init
                Write-Host "  [+] git init" -ForegroundColor Green
            }
        }
        #endregion

        #region Set remote
        $remoteUrl = "https://github.com/$fullName.git"
        $existingRemote = git remote get-url origin 2>&1
        if ($LASTEXITCODE -ne 0) {
            if (-not $DryRun) {
                git remote add origin $remoteUrl
                Write-Host "  [+] git remote add origin $remoteUrl" -ForegroundColor Green
            }
            else {
                Write-Host "  [DRY RUN] git remote add origin $remoteUrl" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Host "  [=] Remote 'origin' již existuje: $existingRemote" -ForegroundColor Gray
        }
        #endregion

        #region Check for uncommitted changes
        $status = git status --porcelain
        if ($status) {
            Write-Host "  Commitování změn..." -ForegroundColor Yellow
            if (-not $DryRun) {
                git add -A
                git commit -m "Initial: $($repo.Description)"
                Write-Host "  [+] git commit" -ForegroundColor Green
            }
            else {
                Write-Host "  [DRY RUN] git add -A && git commit" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Host "  [=] Žádné změny k commitnutí" -ForegroundColor Gray
        }
        #endregion

        #region Set branch and push
        $currentBranch = git branch --show-current
        if (-not $currentBranch) {
            if (-not $DryRun) {
                git branch -M main
                Write-Host "  [+] git branch -M main" -ForegroundColor Green
            }
        }

        Write-Host "  Pushuji na origin..." -ForegroundColor Yellow
        if (-not $DryRun) {
            git push -u origin main 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [+] Push úspěšný!" -ForegroundColor Green
            }
            else {
                Write-Warning "Push selhal. Zkontroluj, že repozitář existuje a máš práva."
            }
        }
        else {
            Write-Host "  [DRY RUN] git push -u origin main" -ForegroundColor DarkGray
        }
        #endregion
    }
    finally {
        Pop-Location
    }
}

Write-Host "`n=== Hotovo! ===" -ForegroundColor Green
Write-Host "https://github.com/$GitHubUser/dotfiles-powershell" -ForegroundColor Cyan
Write-Host "https://github.com/$GitHubUser/dotfiles-tools" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "`nToto byl suchý běh (-DryRun). Pro skutečné provedení spusť bez -DryRun." -ForegroundColor Yellow
}
