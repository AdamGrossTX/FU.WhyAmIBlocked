Function Extract-XMLFromSDB {
    [cmdletbinding()]
    Param (
        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $Script:Config.Path,

        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $PythonPath = $Script:Config.PythonPath,
        
        [parameter(Position = 3, Mandatory = $false)]
        [string]
        $SDBFileInput,
        
        [parameter(Position = 4, Mandatory = $false)]
        [string]
        $SDBCab = $Script:Config.SDBCab
    )

    $WorkingPath = Join-Path -Path $Path -ChildPath "$($DeviceName)"
    $CABPath = "$($WorkingPath)\$($SDBCab)"
    $SDBUnPackerFile = Join-Path -Path $PSScriptRoot -ChildPath "SDBUnpacker.py"
    $AppraiserPath = Join-Path -Path $WorkingPath -ChildPath "Appriser"
    $sdb2xmlPath = Join-Path -Path $PSScriptRoot -ChildPath "sdb2xml.exe"

    New-Item -Path $AppraiserPath -ItemType Directory -Force
    If(Test-Path -Path $CABPath) {
        & expand $CABPath -F:* $AppraiserPath
    }
    Else {
        Copy-Item -Path $SDBFileInput -Destination $AppraiserPath
    }

    $SDBFiles = Get-Item -Path $AppraiserPath\*.sdb -ErrorAction SilentlyContinue
    ForEach ($File in $SDBFiles) {
        $ExpandedFileName = "$($WorkingPath)\$($File.Name)_Expanded.sdb"
        $XMLFileName = "$($WorkingPath)\$($File.Name).XML"
        & $PythonPath $SDBUnPackerFile -i $File.FullName -o $ExpandedFileName
        & $sdb2xmlPath $ExpandedFileName -out $XMLFileName
    }

}