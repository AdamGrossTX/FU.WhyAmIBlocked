Function Get-Blocks {
    [cmdletbinding()]
    Param(

        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $DeviceName = $env:computername,

        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $OutputPath = $config.Path,

        [parameter(Position = 3, Mandatory = $false)]
        [string]
        $BinFilePath,

        [parameter(Position = 4, Mandatory = $false)]
        [switch]
        $ProcessPantherLogs,

        [parameter(Position = 4, Mandatory = $false)]
        [switch]
        $RunCompatAppraiser, #Only runs on local device. Need to add logic to run on remote device.

        [switch]
        $LookupSDBInfo
    )

    Try {

        $OutputPath = Join-Path -Path $OutputPath -ChildPath "$($DeviceName)"
        New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $OutputPath\* -Recurse -ErrorAction SilentlyContinue
        
        $ResultFile = "$($OutputPath)\Results.txt"
        New-Item -Path $ResultFile -ItemType "File" -Force
        Add-Content -Path $ResultFile -Value "$($DeviceName) - $(Get-Date)" -PassThru

        If(!($BinFilePath)) {
            $RootPath = "\\$($DeviceName)\c`$"
        }
        
        $BinFilePath = Join-Path -Path $RootPath -ChildPath "Windows\appcompat\appraiser\*.bin"
        $WindowsBTPath = Join-Path -Path $RootPath -ChildPath "`$WINDOWS.~BT"

        $BinFiles = Get-BinFiles -DeviceName $DeviceName -Path $BinFilePath

        If($RunCompatAppraiser.IsPresent -and $DeviceName -eq $env:computername) {
            Start-CompatAppraiser
        }

        If($BinFiles) {
            Add-Content -Path $ResultFile -Value "Found $($BinFiles.Count) .bin file(s)." -PassThru
            ForEach ($BinFile in $BinFiles) {
                ConvertFrom-BinToXML -InputFile $BinFile -OutputPath $OutputPath
            }
        }
        Else {
            Add-Content -Path $ResultFile -Value "No .bin Files Found." -PassThru
        }

        If($ProcessPantherLogs.IsPresent) {
            Copy-Item (Join-Path -Path $WindowsBTPath -ChildPath "Sources\Panther\*APPRAISER_HumanReadable.xml") $OutputPath -ErrorAction SilentlyContinue 
        }
        
        $XMLFiles = Get-Item -Path "*Humanreadable.xml" -ErrorAction SilentlyContinue
        [System.Collections.ArrayList]$BlockList = @()
        ForEach($File in $XMLFiles) { 
            Search-XMLForBlocks -InputFile $File -OutputPath $OutputPath -OutVariable $blocks
            $BlockList.Add($blocks)
        } 
        
        Add-Content -Path $ResultFile -Value "AppCompat Registry Flags" -PassThru
        Add-Content -Path $ResultFile -Value "==============" -PassThru
        Add-Content -Path $ResultFile -Value (Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser') -PassThru
        Add-Content -Path $ResultFile -Value (Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser\SEC') -PassThru
        Add-Content -Path $ResultFile -Value (Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser\GWX') -PassThru

        If($ProcessPantherLogs.IsPresent) {
            Copy-Item -Path (Join-Path -Path $WindowsBTPath -ChildPath "Sources\Panther\appraiser.sdb") -Destination (Join-Path -Path $OutputPath -ChildPath "BT-Panther-sdb.sdb") -ErrorAction SilentlyContinue
            Copy-Item -Path (Join-Path -Path $WindowsBTPath -ChildPath "Sources\appraiser.sdb") -Destination (Join-Path -Path $OutputPath -ChildPath "BT-sdb.sdb") -ErrorAction SilentlyContinue
            Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\Panther\appraiser.sdb")  -Destination (Join-Path -Path $OutputPath -ChildPath "WIN-Panther-sdb.sdb") -ErrorAction SilentlyContinue
            Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\System32\appraiser\appraiser.sdb")  -Destination (Join-Path -Path $OutputPath -ChildPath "appraiser.sdb") -ErrorAction SilentlyContinue
            Copy-Item -Path (Join-Path -Path $RootPath -ChildPath "Windows\appcompat\appraiser\Appraiser_AlternateData.cab")  -Destination (Join-Path -Path $OutputPath -ChildPath "Appraiser_AlternateData.cab") -ErrorAction SilentlyContinue
        }

        If($LookupSDBInfo) {
            Extract-XMLFromSDB
            Find-BlocksInSDB 
        }

    }
    Catch {
        $Error[0]
    }

}