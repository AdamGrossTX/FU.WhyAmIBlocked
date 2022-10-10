function Get-FULatestModuleVersion {
    param (
        [parameter(Mandatory = $false)]
        [string]
        $ModuleName = $MyInvocation.MyCommand.Name,

        [parameter(Mandatory = $false)]
        [switch]
        $AutoUpdate = $script.config.AutoUpdate.IsPresent
    )

    try {
        $Installed = Get-Module -Name $ModuleName -ListAvailable
        $MaxInstalledVersion = ($Installed.Version | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)
        $online = Find-Module -Name $ModuleName
        $MaxOnlineVersion = ($Online.Version | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)

        if ($MaxInstalledVersion -lt $MaxOnlineVersion) {
            Write-Host " + A new version ($($MaxOnlineVersion)) of $($ModuleName) is available. Please update to use the latest module." -ForegroundColor Yellow

            if ($AutoUpdate.IsPresent) {
                Write-Host " + Auto installing $($ModuleName) version $($MaxOnlineVersion)." -ForegroundColor green
                Install-Module -Name $ModuleName -AllowClobber -Force
                Import-Module -Name $ModuleName -Force
                Write-Host $Script:tick -ForegroundColor green
            }
            else {
                Write-Host " + Run 'Install-Module $($ModuleName) -AllowClobber -Force'" -ForegroundColor Yellow
            }
        }

        if ($AutoUpdate.IsPresent) {
            #$Latest = Get-InstalledModule $ModuleName
            #Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force
        }
    }
    catch {
        throw $_
    }

}