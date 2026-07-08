<#
.SYNOPSIS
    Docker submenu with arrow-key navigation.
.NOTES
    Cesta: ~/Projects/tools/menu/menu-docker.ps1
#>

function Show-DockerMenu {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Err "Docker is not installed or not in PATH."
        Read-Host "`nStiskni Enter..."; return
    }
    $items = [ordered]@{
        '1. 📦 Containers' = @{ Action = { docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'; Read-Host "`nStiskni Enter..." }; Desc = 'List all containers with status and ports' }
        '2. 🖼️  Images'     = @{ Action = { docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'; Read-Host "`nStiskni Enter..." }; Desc = 'List all images with size' }
        '3. 📊 Stats'      = @{ Action = { docker stats --no-stream; Read-Host "`nStiskni Enter..." }; Desc = 'Live CPU/memory per container' }
        '4. 💾 Disk'       = @{ Action = { docker system df; Read-Host "`nStiskni Enter..." }; Desc = 'Docker disk usage summary' }
        '5. 📜 Logs'       = @{ Action = { $n = Read-Host 'Container name'; docker logs --tail 50 $n 2>&1; Read-Host "`nStiskni Enter..." }; Desc = 'Last 50 log lines from a container' }
        '6. ↩️  Back'       = @{ Action = { return }; Desc = 'Return to main menu' }
    }
    Show-Menu -Title 'DOCKER' -Items $items
}

if ($MyInvocation.InvocationName -ne '.') {
    $modulePath = Join-Path $PSScriptRoot '..\Toolkit\Toolkit.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
    Show-DockerMenu
}
