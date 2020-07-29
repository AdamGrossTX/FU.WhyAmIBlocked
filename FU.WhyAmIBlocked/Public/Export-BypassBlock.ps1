<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
Function Export-BypassBlock {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [string]
        $Path = $script:Config.Path
    )

    Try {
        Write-Host " + Finding and exporting block bypass.. " -ForegroundColor Cyan -NoNewline

        $WorkingPath = $Path
        $Files = Get-Item -Path "$($Path)\*.json"

        ForEach($File in $Files) {
            $obj = Get-Content -Path $File -Raw | ConvertFrom-Json
            ForEach($Item in $obj.PSObject.Properties) {
                $BlockName = $item.Value | Where-Object {$_.Name -eq "APP_NAME"} | Select-Object -ExpandProperty Value
                $BlockGUID = $item.Name
                $RegKeys = $item.Value | Where-Object {$_.ParentNode -eq "MATCHING_REG"}
                If($RegKeys) {
                    $NAME = $RegKeys | Where-Object {$_.Name -eq "NAME"} | Select-Object -ExpandProperty Value
                    $REG_VALUE_NAME = $RegKeys | Where-Object {$_.Name -eq "REG_VALUE_NAME"} | Select-Object -ExpandProperty Value
                    #$REG_VALUE_TYPE = $RegKeys | Where-Object {$_.Name -eq "REG_VALUE_TYPE"} | Select -ExpandProperty Value
                    $REG_VALUE_DATA_DWORD = $RegKeys | Where-Object {$_.Name -eq "REG_VALUE_DATA_DWORD"} | Select-Object -ExpandProperty Value

                    $OutRegFile = Join-Path -Path $WorkingPath -ChildPath "$($File.BaseName)_BypassFUBlock.reg"
                    $OutPS1File = Join-Path -Path $WorkingPath -ChildPath "$($File.BaseName)_BypassFUBlock.ps1"

                    If(!(Test-Path $OutRegFile)) {
                        "Windows Registry Editor Version 5.00" | Out-File -FilePath $OutRegFile -Append
                    }
                    "`n; Bypass Block for $($BlockName) - $($BlockGUID)" | Out-File -FilePath $OutRegFile -Append
                    "[HKEY_LOCAL_MACHINE\$($NAME)]" | Out-File -FilePath $OutRegFile -Append
                    "`"$($REG_VALUE_NAME)`"=dword:00000001" | Out-File -FilePath $OutRegFile -Append

                    If(!(Test-Path $OutPS1File)) {
                        "New-Item -Path `"HKLM:\$($NAME)`" -Force | Out-Null" | Out-File -FilePath $OutPS1File -Append
                    }
                    "`n#Bypass Block for $($BlockName) - $($BlockGUID)" | Out-File -FilePath $OutPS1File -Append
                    "New-ItemProperty -Path `"HKLM:\$($NAME)`" -Name `"$($REG_VALUE_NAME)`" -Value `"$($REG_VALUE_DATA_DWORD)`" -PropertyType DWord -Force | Out-Null" | Out-File -FilePath $OutPS1File -Append

                }
            }
        }

        Write-Host $Script:tick -ForegroundColor green
    }
    Catch {
        Write-Warning $_
    }

}
