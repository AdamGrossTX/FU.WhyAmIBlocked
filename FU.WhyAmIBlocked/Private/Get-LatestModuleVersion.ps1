Function Get-LatestModuleVersion {
Param (
    [Parameter(Mandatory=$false)]
    [string]
    $ModuleName = $MyInvocation.MyCommand.Name,

    [Parameter(Mandatory=$false)]
    [switch]
    $AutoUpdate = $script.config.AutoUpdate.IsPresent
)

    Try {
        $Installed = Get-Module -Name $ModuleName -ListAvailable
        $MaxInstalledVersion = ($Installed.Version | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)
        $online = Find-Module -Name $ModuleName
        $MaxOnlineVersion = ($Online.Version | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)

        If($MaxInstalledVersion -lt $MaxOnlineVersion) {
            Write-Host " + A new version ($($MaxOnlineVersion)) of $($ModuleName) is available. Please update to use the latest module." -ForegroundColor Yellow

            If($AutoUpdate.IsPresent) {
                Write-Host " + Auto installing $($ModuleName) version $($MaxOnlineVersion)." -ForegroundColor green
                Install-Module -Name $ModuleName -AllowClobber -Force
                Import-Module -Name $ModuleName -Force
                Write-Host $Script:tick -ForegroundColor green
            }
            Else {
                Write-Host " + Run 'Install-Module $($ModuleName) -AllowClobber -Force'" -ForegroundColor Yellow
            }
        }

        If($AutoUpdate.IsPresent) {
            #$Latest = Get-InstalledModule $ModuleName
            #Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force
        }
    }
    Catch {
        Throw $_
    }

}