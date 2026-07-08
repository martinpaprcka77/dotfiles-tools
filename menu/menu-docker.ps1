<#
.SYNOPSIS
    Docker submenu with arrow-key navigation.
.DESCRIPTION
    Interactive Docker container and image management.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-docker.ps1
#>

function Show-DockerMenu {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Err "Docker není nainstalován nebo není v PATH."
        Read-Host "`nStiskni Enter..."
        return
    }

    $items = [ordered]@{
        '1. 📦 Containers (ps -a)' = { docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'; Read-Host "`nStiskni Enter..." }
        '2. 🖼️  Images'             = { docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'; Read-Host "`nStiskni Enter..." }
        '3. 📊 Stats'              = { docker stats --no-stream; Read-Host "`nStiskni Enter..." }
        '4. 💾 Disk usage'         = { docker system df; Read-Host "`nStiskni Enter..." }
        '5. 📜 Logs'               = { $name = Read-Host 'Název kontejneru'; docker logs --tail 50 $name 2>&1; Read-Host "`nStiskni Enter..." }
        '6. ↩️  Back'               = { return }
    }

    Show-Menu -Title 'DOCKER' -Items $items
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-DockerMenu
}
