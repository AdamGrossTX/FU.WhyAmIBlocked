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

        $ConfigPath = If($($initCfg["ConfigPath"])) {
            "$($initCfg["ConfigPath"])\Config.json"
        }
        Else {
            "$($initCfg["Path"])\Config.json"
        }

        Write-Host " + Creating $($ConfigPath).. " -ForegroundColor Cyan -NoNewline
        if ((Test-Path $ConfigPath -ErrorAction SilentlyContinue) -and ($Reset -eq $false)) {
            Write-Host "$script:tick (Already created - no need to run this again..)" -ForegroundColor Green
        }
        else {
            $initCfgJSON = $initCfg | ConvertTo-Json -Depth 20
            $initCfgJSON | Out-File $ConfigPath -Encoding ascii -Force
            $ConfigPath | Out-File "$env:USERPROFILE\.$($Prefix)cfgpath" -Encoding ascii -Force
            Write-Host $script:tick -ForegroundColor Green
            $script:Config = Get-Config
        }
    }
    catch {
        $Error[0]
    }
}