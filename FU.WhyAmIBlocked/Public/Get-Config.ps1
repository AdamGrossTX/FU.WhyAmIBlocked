
function Get-Config {
    [cmdletbinding()]
    param (
    )
    try {
        $configFileName = "$($initCfg["Prefix"])config"
        $configFilePath = "$env:USERPROFILE\.$($Prefix)cfgpath"
            If(Test-Path -Path $configFilePath) {
                $Config = Get-Content -Path "$(Get-Content -Path $configFilePath -ErrorAction SilentlyContinue)" -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
                New-Variable -Name "$($configFileName)" -Value $Config -Force
                return (Get-Variable $configFileName).value
            }
        else {
            throw "Couldnt find configuration file - please run Initialize-$($Prefix)Module to create the configuration file."
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}