<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
function Export-FUBypassBlock {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)]
        [string]
        $Path = $script:Config.Path
    )

    try {
        Write-Host " + Finding and exporting block bypass.. " -ForegroundColor Cyan -NoNewline

        $WorkingPath = $Path
        $Files = Get-Item -Path "$($Path)\*.json"

        foreach ($File in $Files) {
            $obj = Get-Content -Path $File -Raw | ConvertFrom-Json
            foreach ($Item in $obj.PSObject.Properties) {
                $BlockName = $item.Value | Where-Object { $_.Name -eq "APP_NAME" } | Select-Object -ExpandProperty Value
                $BlockGUID = $item.Name
                $RegKeys = $item.Value | Where-Object { $_.ParentNode -eq "MATCHING_REG" }
                if ($RegKeys) {
                    $NAME = $RegKeys | Where-Object { $_.Name -eq "NAME" } | Select-Object -ExpandProperty Value
                    $REG_VALUE_NAME = $RegKeys | Where-Object { $_.Name -eq "REG_VALUE_NAME" } | Select-Object -ExpandProperty Value
                    #$REG_VALUE_TYPE = $RegKeys | Where-Object {$_.Name -eq "REG_VALUE_TYPE"} | Select -ExpandProperty Value
                    $REG_VALUE_DATA_DWORD = $RegKeys | Where-Object { $_.Name -eq "REG_VALUE_DATA_DWORD" } | Select-Object -ExpandProperty Value

                    $OutRegFile = Join-Path -Path $WorkingPath -ChildPath "$($File.BaseName)_BypassFUBlock.reg"
                    $OutPS1File = Join-Path -Path $WorkingPath -ChildPath "$($File.BaseName)_BypassFUBlock.ps1"

                    if (!(Test-Path $OutRegFile)) {
                        "Windows Registry Editor Version 5.00" | Out-File -FilePath $OutRegFile -Append -Encoding utf8
                    }
                    "`n; Bypass Block for $($BlockName) - $($BlockGUID)" | Out-File -FilePath $OutRegFile -Append -Encoding utf8
                    "[HKEY_LOCAL_MACHINE\$($NAME)]" | Out-File -FilePath $OutRegFile -Append -Encoding utf8
                    "`"$($REG_VALUE_NAME)`"=dword:00000001" | Out-File -FilePath $OutRegFile -Append -Encoding utf8

                    if (!(Test-Path $OutPS1File)) {
                        "New-Item -Path `"HKLM:\$($NAME)`" -Force | Out-Null" | Out-File -FilePath $OutPS1File -Append -Encoding utf8
                    }
                    "`n#Bypass Block for $($BlockName) - $($BlockGUID)" | Out-File -FilePath $OutPS1File -Append -Encoding utf8
                    "New-ItemProperty -Path `"HKLM:\$($NAME)`" -Name `"$($REG_VALUE_NAME)`" -Value `"$($REG_VALUE_DATA_DWORD)`" -PropertyType DWord -Force | Out-Null" | Out-File -FilePath $OutPS1File -Append -Encoding utf8

                }
            }
        }

        Write-Host $Script:tick -ForegroundColor green
    }
    catch {
        Write-Warning $_
    }

}
