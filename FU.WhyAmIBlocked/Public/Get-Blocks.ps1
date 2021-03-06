<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
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

        #Get-LatestModuleVersion

        Write-Host " + Creating Output Folders $($OutputPath).. " -ForegroundColor Cyan -NoNewline
        $Date = (Get-Date -Format yyyyMMdd_hhmmss)

        If($Local.IsPresent -or (!($DeviceName)) -and (!($AlternateSourcePath))) {
            $DeviceName = $env:computername
        }

        If($DeviceName) {
            $tOutputPath = Join-Path -Path $Path -ChildPath "$($DeviceName)_$($Date)"
        }
        Else {
            $DeviceName = "NoDeviceName"
            $tOutputPath = "$($Path)\Output_$($Date)"
        }

        $OutputPath = New-Item -Path $tOutputPath -ItemType Directory -Force -ErrorAction SilentlyContinue

        $ResultFile = New-Item -Path "$($OutputPath)\Results.txt" -ItemType "File" -Force
        Add-Content -Path $ResultFile -Value "$($DeviceName) - $(Get-Date)"

        $BinFilePath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "Bin") -ItemType Directory -Force
        $AppraiserDataPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "AppraiserData") -ItemType Directory -Force
        $CABPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "CABs") -ItemType Directory -Force
        $XMLPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "XML") -ItemType Directory -Force
                
        Write-Host $script:tick -ForegroundColor Green

        If(!($AlternateSourcePath)) {
            If($DeviceName -eq $env:computername) {
                $RootPath = "c:"
            }
            Else {
                $RootPath = "\\$($DeviceName)\c`$"
            }
            $AppraiserSourcePath = Join-Path -Path $RootPath -ChildPath "Windows\appcompat\appraiser"
            $WindowsBTSourcePath = Join-Path -Path $RootPath -ChildPath "`$WINDOWS.~BT"
            $WindowsPantherSourcePath = Join-Path -Path $RootPath -ChildPath "Windows\Panther"
        }
        Else {
            $RootPath = $AlternateSourcePath
            $AppraiserSourcePath = $RootPath
            $WindowsBTSourcePath = $null
            $WindowsPantherSourcePath = $null
        }

        If($RunCompatAppraiser.IsPresent -and $DeviceName -eq $env:computername) {
            Start-CompatAppraiser
        }
        
        Write-Host " + Getting .source files.. " -ForegroundColor Cyan

        $SourceFiles = @{}
        If($AlternateSourcePath) {
            $SourceFiles["AltSrc"] = @(
                    (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.sdb") -ErrorAction SilentlyContinue)
                    (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.cab") -ErrorAction SilentlyContinue)
                    (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.xml") -ErrorAction SilentlyContinue)
                    (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.bin") -ErrorAction SilentlyContinue)
                )
        }
        Else {
            $SourceFiles["AppCompatAppraiser"] = @(
                (Get-Item -Path (Join-Path -Path $AppraiserSourcePath -ChildPath "*.cab") -ErrorAction SilentlyContinue)
                (Get-Item -Path (Join-Path -Path $AppraiserSourcePath -ChildPath "*.bin") -ErrorAction SilentlyContinue)
            )

            $SourceFiles["System32Appraiser"] = @(
                (Get-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\System32\appraiser\*.sdb") -ErrorAction SilentlyContinue)
                (Get-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\System32\appraiser\*.ini") -ErrorAction SilentlyContinue)
            )

            If($ProcessPantherLogs.IsPresent) {
                $SourceFiles["WindowsBTSourcesPanther"] = @(
                    (Get-Item -Path (Join-Path -Path $WindowsBTSourcePath -ChildPath "Sources\Panther\*APPRAISER_HumanReadable.xml") -ErrorAction SilentlyContinue)
                    (Get-Item -Path (Join-Path -Path $WindowsBTSourcePath -ChildPath "Sources\Panther\AltData.cab") -ErrorAction SilentlyContinue)
                )

                $SourceFiles["WindowsBTSources"] = @(
                    (Get-Item -Path (Join-Path -Path $WindowsBTSourcePath -ChildPath "Sources\*APPRAISER_HumanReadable.xml") -ErrorAction SilentlyContinue)
                    (Get-Item -Path (Join-Path -Path $WindowsBTSourcePath -ChildPath "Sources\AltData.cab") -ErrorAction SilentlyContinue)
                )

                $SourceFiles["WindowsPanther"] = @(
                    (Get-Item -Path (Join-Path -Path $WindowsPantherSourcePath -ChildPath "*APPRAISER_HumanReadable.xml") -ErrorAction SilentlyContinue)
                    (Get-Item -Path (Join-Path -Path $WindowsPantherSourcePath -ChildPath "AltData.cab") -ErrorAction SilentlyContinue)
                )
            }
        }

        ForEach($key in $SourceFiles.Keys) {
            ForEach($File in $SourceFiles[$key]) {
                $DestPath = Switch ($File.Extension) {
                    ".xml" {$XMLPath}
                    ".cab" {$CabPath}
                    ".sdb" {$AppraiserDataPath}
                    ".ini" {$AppraiserDataPath}
                    ".bin" {$BinFilePath}
                    default {}
                }
                If($key -eq "System32Appraiser") {
                    $DestPath = New-Item -Path "$($AppraiserDataPath)\$Key" -ItemType Directory -Force -ErrorAction SilentlyContinue
                }
                Write-Host " ++ copying $($File.FullName) to $($DestPath)" -ForegroundColor Cyan -NoNewline
                $File | Copy-Item -Destination "$($DestPath)\$($Key)_$($File.Name)" -Force -ErrorAction SilentlyContinue
                Write-Host $script:tick -ForegroundColor Green
            }
        }

        $BinFiles = Get-Item -Path (Join-Path -Path $BinFilePath -ChildPath "*.bin") -ErrorAction SilentlyContinue
        If($BinFiles) {
            Add-Content -Path $ResultFile -Value "Found $($BinFiles.Count) .bin file(s)."
            Add-Content -Path $ResultFile -Value "$($BinFiles | Format-Table | Out-String)"
            ConvertFrom-BinToXML -FileList $BinFiles -OutputPath $XMLPath
        }
        Else {
            Add-Content -Path $ResultFile -Value "No .bin Files Found."
        }

        $HumanReadableXMLFiles = Get-Item -Path "$($XMLPath)\*Humanreadable.xml" -ErrorAction SilentlyContinue

        If($HumanReadableXMLFiles) {
            $Script:BlockList = Get-BlocksFromBin -FileList $HumanReadableXMLFiles -ResultFile $ResultFile -Output (New-Object -TypeName System.Collections.ArrayList )
        }
        Else {
            Write-Warning "No XML Files found to process. Verify that BIN/XML files were provided. Exiting."
            Return
        }

        #Needs to work with remote devices too...
        If($DeviceName -eq $env:computername) {
            Add-Content -Path $ResultFile -Value "AppCompat Registry Flags"
            Add-Content -Path $ResultFile -Value "=============="
            Add-Content -Path $ResultFile -Value (Get-Item -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser' -ErrorAction SilentlyContinue)
            Add-Content -Path $ResultFile -Value (Get-Item -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser\SEC' -ErrorAction SilentlyContinue)
            Add-Content -Path $ResultFile -Value (Get-Item -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser\GWX' -ErrorAction SilentlyContinue)
        }

        If(!($SkipSDBInfo.IsPresent)) {
            Export-XMLFromSDB -Path $OutputPath
            If($Script:BlockList) {
                Find-BlocksInSDB -Path $OutputPath
                Export-BypassBlock -Path $OutputPath
            }
            Else {
                Write-Host " + No blocks Found. Congratulations!!.. " -ForegroundColor Cyan -NoNewline
                Write-Host $Script:tick -ForegroundColor green
            }
        }

        Write-Host "Appraiser Results can be found: $($OutputPath)\Results.txt" -ForegroundColor Green
    }
    Catch {
        Write-Warning $_
        throw
    }

}