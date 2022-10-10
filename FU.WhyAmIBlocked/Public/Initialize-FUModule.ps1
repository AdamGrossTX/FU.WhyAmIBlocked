<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
function Initialize-FUModule {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $false)]
        $initCfg,

        [parameter(Position = 2, Mandatory = $false)]
        [switch]
        $Reset
    )
    try {

        if ($Reset.IsPresent) {
            if ($initcfg) {
                $initCfg
            }
            else {
                $initCfg = $script:initCfg
            }
        }
        else {
            $initCfg = $Script:Config
        }

        $path = $initCfg.Path
        if (!(Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }


        $ConfigFile =
        if ($initCfg.ConfigFile) {
            $initCfg.ConfigFile
        }
        else {
            "$($Path)\Config.json"
        }

        Write-Host " + Creating $($ConfigFile).. " -ForegroundColor Cyan -NoNewline
        if ((Test-Path $ConfigFile -ErrorAction SilentlyContinue) -and (!($Reset.IsPresent))) {
            Write-Warning "Already created - no need to run this again.."
        }
        else {
            $initCfgJSON = $initCfg | ConvertTo-Json -Depth 20
            $initCfgJSON | Out-File $ConfigFile -Encoding utf8 -Force
            $ConfigFile | Out-File $initCfg.UserConfigFile -Encoding utf8 -Force
            Write-Host $script:tick -ForegroundColor Green
        }
    }
    catch {
        Write-Warning $_
    }
}