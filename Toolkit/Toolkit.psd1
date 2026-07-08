@{
    # Module manifest for Toolkit
    RootModule        = 'Toolkit.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'USER'
    CompanyName       = ''
    Copyright         = '(c) 2026. MIT License.'
    Description       = 'Osobní PowerShell toolbox – menu, diagnostika, pomocné funkce.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Test-Admin',
        'Get-ScriptDirectory',
        'Write-Info',
        'Write-Success',
        'Write-Warn',
        'Write-Err',
        'Confirm-Action',
        'Show-Menu',
        'Start-MainMenu',
        'Show-DockerMenu',
        'Show-GitMenu',
        'Show-TerminalMenu',
        'Show-DotfilesMenu',
        'Show-PwshMenu',
        'Show-VSCodeMenu',
        'Get-DiskStatus',
        'Get-ServiceStatus',
        'Get-NetworkInfo',
        'Get-TopProcesses',
        'Invoke-SystemCheck',
        'Get-ToolkitConfig',
        'Save-ToolkitConfig',
        'Merge-Hashtable'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags       = @('tools', 'menu', 'diagnostics', 'powershell')
            LicenseUri = 'https://github.com/martinpaprcka77/dotfiles-tools/blob/main/LICENSE'
            ProjectUri = 'https://github.com/martinpaprcka77/dotfiles-tools'
        }
    }
}
