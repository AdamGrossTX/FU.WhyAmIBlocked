<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
Function Export-XMLFromSDB {
    [cmdletbinding()]
    Param (

        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $Script:Config.Path,

        [parameter(Position = 5, Mandatory = $false)]
        [string]
        $AlternateSourcePath
    )

    $Date = (Get-Date -Format yyyyMMdd_hhmmss)
    If(!($Path)) {
        $Path = $Script:Config.Path
    }

    If($AlternateSourcePath) {
        $WorkingPath = $AlternateSourcePath
        $OutputPath = New-Item -Name "ExportedSDB_$Date" -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    Else {
        $WorkingPath = $Path
        $OutputPath = $Path
    }

    Try {
        If(!(Test-Path $script:Config.sdb2xmlPath)) {
            Write-Warning "Cannot extract SDB files. sdb2XML not found at path: $($script:Config.sdb2xmlPath)"
        }
        Else {

            $CABPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "CABs") -ItemType Directory -Force
            $AppraiserDataPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "AppraiserData") -ItemType Directory -Force

            If($AlternateSourcePath) {
                Write-Host " + Copying files from $($AlternateSourcePath).. " -ForegroundColor Cyan
                If(Test-Path "$($AlternateSourcePath)" -ErrorAction SilentlyContinue) {
                    $Files = @(
                        (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.sdb") -ErrorAction SilentlyContinue)
                        (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.cab") -ErrorAction SilentlyContinue)
                    )
                    ForEach($File in $Files) {
                        $DestPath = Switch ($File.Extension) {
                            ".cab" {"$($CabPath)\AltSrc_$($File.Name)"}
                            ".sdb" {"$($AppraiserDataPath)\AltSrc_$($File.Name)"}
                            ".ini" {"$($AppraiserDataPath)\AltSrc_$($File.Name)"}
                            default {}
                        }
                        Write-Host " ++ copying $($File.FullName) to $($DestPath)" -ForegroundColor Cyan -NoNewline
                        $File | Copy-Item -Destination $DestPath -Force -ErrorAction SilentlyContinue
                        Write-Host $script:tick -ForegroundColor Green
                    }
                    Write-Host $Script:tick -ForegroundColor green
                }
                Else {
                    Write-Warning "AlternateSourcePath $($AlternateSourcePath) Not Found."
                }
            }

            $Cabs = Get-ChildItem -Path (Join-Path -Path $CABPath -ChildPath "*.cab") -Recurse -ErrorAction SilentlyContinue
            ForEach($Cab in $Cabs) {
                Write-Host " + Extracting $($Cab.FullName).. " -ForegroundColor Cyan -NoNewline
                $newCabPath = New-Item -Path "$($AppraiserDataPath)\$($Cab.BaseName)" -ItemType Directory -Force -ErrorAction SilentlyContinue
                & expand $Cab -F:* $newCabPath | Out-Null
                $SDBFiles = Get-Item -Path "$($AppraiserDataPath)\$($Cab.BaseName)\*.sdb" -ErrorAction SilentlyContinue
                If(!($SDBFiles)) {
                    Write-Warning "No .sdb files found in $($AppraiserDataPath)\$($Cab.Name)"
                }
                Else {
                    Write-Host $Script:tick -ForegroundColor green
                }
            }

            Write-Host " + Finding .sdb files.. " -ForegroundColor Cyan -NoNewline
            $SDBFiles = Get-ChildItem -Path $AppraiserDataPath\*.sdb -Recurse -ErrorAction SilentlyContinue
            If($SDBFiles) {
                ForEach ($File in $SDBFiles) {
                    $Parent = Split-Path $File -Parent
                    $ParentName = Split-Path $Parent -Leaf

                    $IniContent = Get-Content -Path "$($Parent)\*.ini" -TotalCount 2 -ErrorAction SilentlyContinue
                    If($IniContent) {
                        $Version = ($IniContent[1].Split("="))[1]
                    }
                    Else {
                        $Version = "unknown"
                    }

                    $ExpandedFileName = "$(Split-Path $File -Parent)\$($File.Name)_Expanded_ver_$($Version).sdb"
                    $XMLFileName = "$($OutputPath)\$($ParentName)_$($File.Name)_ver_$($Version).XML"
                    Write-Host $Script:tick -ForegroundColor green
                    Expand-SDB -Path $File.DirectoryName $File -InputFile $File.FullName -OutputFile $ExpandedFileName
                    Write-Host " + Converting sdb to xml.. " -ForegroundColor Cyan -NoNewline
                    & "$($script:Config.sdb2xmlPath)" $ExpandedFileName -out $XMLFileName | Out-Null
                    Write-Host $Script:tick -ForegroundColor green
                }
            }
            Else {
                Write-Warning "No SDB Files found at path: $($AppraiserDataPath)."
            }
        }
    }
    Catch {
        Write-Warning $_
    }
}