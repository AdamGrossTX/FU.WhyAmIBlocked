<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
function Initialize-Module {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $false)]
        $initCfg,

        [parameter(Position = 2, Mandatory = $false)]
        [switch]
        $Reset
    )
    try {

        If($Reset.IsPresent) {
            If($initcfg) {
                $initCfg
            }
            Else {
                $initCfg = $script:initCfg
            }
        }
        Else {
            $initCfg = $Script:Config
        }

        $path = $initCfg.Path
        If(!(Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }


        $ConfigFile =
            If($initCfg.ConfigFile) {
                $initCfg.ConfigFile
            }
            Else {
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