Function Get-Blocks {
    [cmdletbinding(DefaultParameterSetName="Local")]
    Param(

        [parameter(Position = 1, Mandatory = $false, ParameterSetName='Local')]
        [switch]
        $Local,

        [parameter(Position = 2, Mandatory = $false, ParameterSetName='Local')]
        [switch]
        $RunCompatAppraiser, #Only runs on local device. Need to add logic to run on remote device.

        [parameter(Position = 1, Mandatory = $true, ParameterSetName='Remote')]
        [parameter(Position = 1, Mandatory = $false, ParameterSetName='Alt')]
        [string]
        $DeviceName,

        [parameter(Position = 3, Mandatory = $false, ParameterSetName='Local')]
        [parameter(Position = 2, Mandatory = $false, ParameterSetName='Remote')]
        [parameter(Position = 2, Mandatory = $true, ParameterSetName='Alt')]
        [string]
        $AlternateSourcePath,
        
        [parameter(Position = 3, Mandatory = $false)]
        [string]
        $Path = $script:config.Path,

        [parameter(Position = 5, Mandatory = $false)]
        [switch]
        $ProcessPantherLogs,

        [parameter(Position = 6, Mandatory = $false)]
        [switch]
        $SkipSDBInfo
        
    )

    Try {

        Write-Host " + Creating Output Folders $($OutputPath).. " -ForegroundColor Cyan -NoNewline
        

        If($Local.IsPresent -or (!($DeviceName)) -and (!($AlternateSourcePath))) {
            $DeviceName = $env:computername
        }

        If($DeviceName) {
            $OutputPath = Join-Path -Path $Path -ChildPath $DeviceName
        }
        Else {
            $DeviceName = "NoDeviceName"
            $OutputPath = "$($Path)\Output"
        }
        
        New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-Item -Path $OutputPath\* -Recurse -ErrorAction SilentlyContinue | Out-Null
        
        $ResultFile = "$($OutputPath)\Results.txt"
        New-Item -Path $ResultFile -ItemType "File" -Force | Out-Null
        Add-Content -Path $ResultFile -Value "$($DeviceName) - $(Get-Date)"

        $AppraiserPath = Join-Path -Path $OutputPath -ChildPath "Appraiser"
        New-Item -Path $AppraiserPath -ItemType Directory -Force | Out-Null
        Write-Host $script:tick -ForegroundColor Green
        
        If(!($AlternateSourcePath)) {
            If($DeviceName -eq $env:computername) {
                $RootPath = "c:"                
            }
            Else {
                $RootPath = "\\$($DeviceName)\c`$"
            }
            $BinFilePath = Join-Path -Path $RootPath -ChildPath "Windows\appcompat\appraiser"
            $WindowsBTPath = Join-Path -Path $RootPath -ChildPath "`$WINDOWS.~BT"
        }
        Else {
            $RootPath = $AlternateSourcePath
            $BinFilePath = $RootPath
            $WindowsBTPath = $null
        }

        $BinFiles = Get-BinFiles -DeviceName $DeviceName -Path $BinFilePath -DestinationPath $OutputPath

        If($RunCompatAppraiser.IsPresent -and $DeviceName -eq $env:computername) {
            Start-CompatAppraiser
        }

        If($BinFiles) {
            Add-Content -Path $ResultFile -Value "Found $($BinFiles.Count) .bin file(s)."
            ConvertFrom-BinToXML -FileList $BinFiles -OutputPath $OutputPath
        }
        Else {
            Add-Content -Path $ResultFile -Value "No .bin Files Found."
        }

        If($ProcessPantherLogs.IsPresent) {
            Copy-Item (Join-Path -Path $WindowsBTPath -ChildPath "Sources\Panther\*APPRAISER_HumanReadable.xml") $OutputPath -ErrorAction SilentlyContinue 
        }
        
        $HumanReadableXMLFiles = (Get-Item -Path "*Humanreadable.xml" -ErrorAction SilentlyContinue).FullName
        $Script:BlockList = Get-BlocksFromBin -FileList $HumanReadableXMLFiles -ResultFile $ResultFile -Output (New-Object -TypeName System.Collections.ArrayList )
        
        #Needs to work with remote devices too...
        If($DeviceName -eq $env:computername) {
            Add-Content -Path $ResultFile -Value "AppCompat Registry Flags"
            Add-Content -Path $ResultFile -Value "=============="
            Add-Content -Path $ResultFile -Value (Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser')
            Add-Content -Path $ResultFile -Value (Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser\SEC')
            Add-Content -Path $ResultFile -Value (Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser\GWX')
        }
        
        If($ProcessPantherLogs.IsPresent) {
            Copy-Item -Path (Join-Path -Path $WindowsBTPath -ChildPath "Sources\Panther\appraiser.sdb") -Destination (Join-Path -Path $AppraiserPath -ChildPath "BT-Panther-sdb.sdb") -ErrorAction SilentlyContinue
            Copy-Item -Path (Join-Path -Path $WindowsBTPath -ChildPath "Sources\appraiser.sdb") -Destination (Join-Path -Path $AppraiserPath -ChildPath "BT-sdb.sdb") -ErrorAction SilentlyContinue
            Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\Panther\appraiser.sdb")  -Destination (Join-Path -Path $AppraiserPath -ChildPath "WIN-Panther-sdb.sdb") -ErrorAction SilentlyContinue
        }

        If(!($SkipSDBInfo.IsPresent)) {
            If(!($AlternateSourcePath)) {
                Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\System32\appraiser\appraiser.sdb")  -Destination (Join-Path -Path $AppraiserPath -ChildPath "appraiser.sdb") -ErrorAction SilentlyContinue
                Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\appcompat\appraiser\$($script:Config.SDBCab)")  -Destination (Join-Path -Path $OutputPath -ChildPath $script:Config.SDBCab) -ErrorAction SilentlyContinue
            }
            Else {
                Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "appraiser.sdb")  -Destination (Join-Path -Path $AppraiserPath -ChildPath "appraiser.sdb") -ErrorAction SilentlyContinue
                Copy-Item -Path (Join-Path -Path $RootPath -ChildPath $script:Config.SDBCab)  -Destination (Join-Path -Path $OutputPath -ChildPath $script:Config.SDBCab) -ErrorAction SilentlyContinue
            }
            Extract-XMLFromSDB -Path $OutputPath
            If($Script:BlockList) {
                Find-BlocksInSDB -Path $OutputPath
                Export-BypassBlock -Path $OutputPath
            }
            Else {
                Write-Host " + No blocks Found. Congratulations!!.. " -ForegroundColor Cyan -NoNewline
                Write-Host $Script:tick -ForegroundColor green
            }
        }

        #region Cleanup
        $tmp = New-Item -Path "$($OutputPath)\tmp" -ItemType Directory -Force
        Get-Item -Path $OutputPath\*.bin | Move-Item -Destination $tmp
        Get-Item -Path $OutputPath\*.cab | Move-Item -Destination $tmp
        Get-Item -Path $OutputPath\*.sdb | Move-Item -Destination $tmp
        Get-Item -Path $OutputPath\*.json | Move-Item -Destination $tmp
        Get-Item -Path $OutputPath\Appraiser | Move-Item -Destination $tmp

        Write-Host "Appraiser Results can be found: $($OutputPath)\Results.txt" -ForegroundColor Green
        Write-Host "Appraiser Database matches can be found: $($OutputPath)\Match.txt" -ForegroundColor Green

    }
    Catch {
        Write-Warning $_
        throw
    }

}