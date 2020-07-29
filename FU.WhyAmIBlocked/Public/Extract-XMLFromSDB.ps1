<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
Function Extract-XMLFromSDB {
    [cmdletbinding()]
    Param (
        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $Script:Config.Path,

        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $SDBFileInput,

        [parameter(Position = 3, Mandatory = $false)]
        [string]
        $SDBCab = $script:Config.SDBCab,

        [parameter(Position = 5, Mandatory = $false)]
        [string]
        $AlternateSourcePath
    )

    Try {
        If($script:PythonInstalled) {
            If(!(Test-Path $script:Config.sdb2xmlPath)) {
                Write-Warning "Cannot extract SDB files. sdb2XML not found at path: $($script:Config.sdb2xmlPath)"
            }
            Else {

                #If(!($AlternateSourcePath)) {
                    $WorkingPath = $Path
                #}
                #Else {
                #    $WorkingPath = $AlternateSourcePath
                #}

                $CABPath = "$($WorkingPath)\$($SDBCab)"
                $AppraiserPath = Join-Path -Path $WorkingPath -ChildPath "Appraiser"

                If($AlternateSourcePath) {
                    Write-Host " + Copying files from $($AlternateSourcePath).. " -ForegroundColor Cyan
                    If(Test-Path "$($AlternateSourcePath)" -ErrorAction SilentlyContinue) {
                        Copy-Item -Path "$($AlternateSourcePath)\*.sdb" -Destination $AppraiserPath -ErrorAction Stop
                        Copy-Item -Path "$($AlternateSourcePath)\$($SDBCab)" -Destination $WorkingPath -ErrorAction Stop
                        Write-Host $Script:tick -ForegroundColor green
                    }
                    Else {
                        Write-Warning "AlternateSourcePath $($AlternateSourcePath) Not Found."
                    }
                }

                If(Test-Path -Path $CABPath) {
                    Write-Host " + Extracting $($CABPath).. " -ForegroundColor Cyan -NoNewline
                    New-Item -Path $AppraiserPath -ItemType Directory -Force | Out-Null
                    & expand $CABPath -F:* $AppraiserPath | Out-Null
                    $SDBFiles = Get-Item -Path $AppraiserPath\*.sdb -ErrorAction SilentlyContinue
                    If(!($SDBFiles)) {
                        Write-Warning "No .sdb files found in $($AppraiserPath)"
                    }
                    Else {
                        Write-Host $Script:tick -ForegroundColor green
                    }
                }

                Write-Host " + Finding .sdb files.. " -ForegroundColor Cyan -NoNewline
                $SDBFiles = Get-Item -Path $AppraiserPath\*.sdb -ErrorAction SilentlyContinue
                If($SDBFiles) {
                    ForEach ($File in $SDBFiles) {
                        $ExpandedFileName = "$($WorkingPath)\$($File.Name)_Expanded.sdb"
                        $XMLFileName = "$($WorkingPath)\$($File.Name).XML"

                        Write-Host $Script:tick -ForegroundColor green

                        Write-Host " + Unpacking $($File.FullName).. " -ForegroundColor Cyan -NoNewline
                        & python.exe "$($script:Config.SDBUnPackerFile)" -i $File.FullName -o $ExpandedFileName | Out-Null
                        Write-Host $Script:tick -ForegroundColor green

                        Write-Host " + Converting sdb to xml.. " -ForegroundColor Cyan -NoNewline
                        & "$($script:Config.sdb2xmlPath)" $ExpandedFileName -out $XMLFileName | Out-Null
                        Write-Host $Script:tick -ForegroundColor green
                    }
                }
                Else {
                    Write-Warning "No SDB Files found at path: $($AppraiserPath)."
                }
            }
        }
        Else {
            Write-Warning "Cannot extract SDB files. Python is not installed."
        }
    }
    Catch {
        Write-Warning $_
    }
}Function Extract-XMLFromSDB {
    [cmdletbinding()]
    Param (
        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $Script:Config.Path,

        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $SDBFileInput,

        [parameter(Position = 3, Mandatory = $false)]
        [string]
        $SDBCab = $script:Config.SDBCab,

        [parameter(Position = 5, Mandatory = $false)]
        [string]
        $AlternateSourcePath
    )

    Try {
        If($script:PythonInstalled) {
            If(!(Test-Path $script:Config.sdb2xmlPath)) {
                Write-Warning "Cannot extract SDB files. sdb2XML not found at path: $($script:Config.sdb2xmlPath)"
            }
            Else {

                If(!($AlternateSourcePath)) {
                    $WorkingPath = $Path
                }
                Else {
                    $WorkingPath = $AlternateSourcePath
                }

                $CABPath = "$($WorkingPath)\$($SDBCab)"
                $AppraiserPath = Join-Path -Path $WorkingPath -ChildPath "Appraiser"

                If($AlternateSourcePath) {
                    Write-Host " + Copying files from $($AlternateSourcePath).. " -ForegroundColor Cyan
                    If(Test-Path "$($AlternateSourcePath)" -ErrorAction SilentlyContinue) {
                        Copy-Item -Path "$($AlternateSourcePath)\*.sdb" -Destination $AppraiserPath -ErrorAction Stop
                        Copy-Item -Path "$($AlternateSourcePath)\$($SDBCab)" -Destination $WorkingPath -ErrorAction Stop
                        Write-Host $Script:tick -ForegroundColor green
                    }
                    Else {
                        Write-Warning "AlternateSourcePath $($AlternateSourcePath) Not Found."
                    }
                }

                If(Test-Path -Path $CABPath) {
                    Write-Host " + Extracting $($CABPath).. " -ForegroundColor Cyan -NoNewline
                    New-Item -Path $AppraiserPath -ItemType Directory -Force | Out-Null
                    & expand $CABPath -F:* $AppraiserPath | Out-Null
                    $SDBFiles = Get-Item -Path $AppraiserPath\*.sdb -ErrorAction SilentlyContinue
                    If(!($SDBFiles)) {
                        Write-Warning "No .sdb files found in $($AppraiserPath)"
                    }
                    Else {
                        Write-Host $Script:tick -ForegroundColor green
                    }
                }

                Write-Host " + Finding .sdb files.. " -ForegroundColor Cyan -NoNewline
                $SDBFiles = Get-Item -Path $AppraiserPath\*.sdb -ErrorAction SilentlyContinue
                If($SDBFiles) {
                    ForEach ($File in $SDBFiles) {
                        $ExpandedFileName = "$($WorkingPath)\$($File.Name)_Expanded.sdb"
                        $XMLFileName = "$($WorkingPath)\$($File.Name).XML"

                        Write-Host $Script:tick -ForegroundColor green

                        Write-Host " + Unpacking $($File.FullName).. " -ForegroundColor Cyan -NoNewline
                        & python.exe "$($script:Config.SDBUnPackerFile)" -i $File.FullName -o $ExpandedFileName | Out-Null
                        Write-Host $Script:tick -ForegroundColor green

                        Write-Host " + Converting sdb to xml.. " -ForegroundColor Cyan -NoNewline
                        & "$($script:Config.sdb2xmlPath)" $ExpandedFileName -out $XMLFileName | Out-Null
                        Write-Host $Script:tick -ForegroundColor green
                    }
                }
                Else {
                    Write-Warning "No SDB Files found at path: $($AppraiserPath)."
                }
            }
        }
        Else {
            Write-Warning "Cannot extract SDB files. Python is not installed."
        }
    }
    Catch {
        Write-Warning $_
    }
}