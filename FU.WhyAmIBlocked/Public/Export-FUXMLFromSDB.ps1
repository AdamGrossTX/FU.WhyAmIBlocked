<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
function Export-FUXMLFromSDB {
    [cmdletbinding()]
    param (

        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $Script:Config.Path,

        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $AlternateSourcePath,

        [parameter(Position = 3, Mandatory = $false)]
        [string[]]
        $NodesToExclude = @(
            "INDEXES",
            "STRINGTABLE",
            "MIGRATION_DATA",
            "MIGRATION_SHIM",
            "INEXCLUDE",
            "SHIM",
            "CONTEXT",
            "LAYER",
            "C_STRUCT",
            "DEVICE_BLOCK",
            "FLAG"
        )
    )

    $Date = (Get-Date -Format yyyyMMdd_hhmmss)
    if (!($Path)) {
        $Path = $Script:Config.Path
    }

    if ($AlternateSourcePath) {
        $WorkingPath = $AlternateSourcePath
        $OutputPath = New-Item -Name "ExportedSDB_$Date" -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    else {
        $WorkingPath = $Path
        $OutputPath = $Path
    }

    try {
        if (!(Test-Path $script:Config.sdb2xmlPath)) {
            Write-Warning "Cannot extract SDB files. sdb2XML not found at path: $($script:Config.sdb2xmlPath)"
        }
        else {

            $CABPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "CABs") -ItemType Directory -Force
            $AppraiserDataPath = New-Item -Path (Join-Path -Path $OutputPath -ChildPath "AppraiserData") -ItemType Directory -Force

            if ($AlternateSourcePath) {
                Write-Host " + Copying files from $($AlternateSourcePath).. " -ForegroundColor Cyan
                if (Test-Path "$($AlternateSourcePath)" -ErrorAction SilentlyContinue) {
                    $Files = @(
                        (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.sdb") -ErrorAction SilentlyContinue)
                        (Get-Item -Path (Join-Path -Path $AlternateSourcePath -ChildPath "*.cab") -ErrorAction SilentlyContinue)
                    )
                    foreach ($File in $Files) {
                        $DestPath = switch ($File.Extension) {
                            ".cab" { "$($CabPath)\AltSrc_$($File.Name)" }
                            ".sdb" { "$($AppraiserDataPath)\AltSrc_$($File.Name)" }
                            ".ini" { "$($AppraiserDataPath)\AltSrc_$($File.Name)" }
                            default {}
                        }
                        Write-Host " ++ copying $($File.FullName) to $($DestPath)" -ForegroundColor Cyan -NoNewline
                        $File | Copy-Item -Destination $DestPath -Force -ErrorAction SilentlyContinue
                        Write-Host $script:tick -ForegroundColor Green
                    }
                    Write-Host $Script:tick -ForegroundColor green
                }
                else {
                    Write-Warning "AlternateSourcePath $($AlternateSourcePath) Not Found."
                }
            }

            $Cabs = Get-ChildItem -Path (Join-Path -Path $CABPath -ChildPath "*.cab") -Recurse -ErrorAction SilentlyContinue
            foreach ($Cab in $Cabs) {
                Write-Host " + Extracting $($Cab.FullName).. " -ForegroundColor Cyan -NoNewline
                $newCabPath = New-Item -Path "$($AppraiserDataPath)\$($Cab.BaseName)" -ItemType Directory -Force -ErrorAction SilentlyContinue
                & expand $Cab -F:* $newCabPath | Out-Null
                $SDBFiles = Get-Item -Path "$($AppraiserDataPath)\$($Cab.BaseName)\*.sdb" -ErrorAction SilentlyContinue
                if (!($SDBFiles)) {
                    Write-Warning "No .sdb files found in $($AppraiserDataPath)\$($Cab.Name)"
                }
                else {
                    Write-Host $Script:tick -ForegroundColor green
                }
            }

            Write-Host " + Finding .sdb files.. " -ForegroundColor Cyan -NoNewline
            $SDBFiles = Get-ChildItem -Path "$($AppraiserDataPath)\*.sdb" -Recurse -ErrorAction SilentlyContinue
            if ($SDBFiles) {
                foreach ($File in $SDBFiles) {
                    $Parent = Split-Path $File -Parent
                    $ParentName = Split-Path $Parent -Leaf

                    $IniContent = Get-Content -Path "$($Parent)\*.ini" -TotalCount 2 -ErrorAction SilentlyContinue
                    if ($IniContent) {
                        $Version = ($IniContent[1].Split("="))[1]
                    }
                    else {
                        $Version = "unknown"
                    }

                    $ExpandedFileName = "$($File.Name)_Expanded_ver_$($Version).sdb"
                    $XMLFileName = "$($OutputPath)\$($ParentName)_$($File.Name)_ver_$($Version).XML"
                    Write-Host $Script:tick -ForegroundColor green
                    Expand-FUSDB -Path $File.DirectoryName -InputFile $File.Name -OutputFile $ExpandedFileName
                    Write-Host " + Converting sdb to xml.. " -ForegroundColor Cyan -NoNewline
                    & "$($script:Config.sdb2xmlPath)" "$(Split-Path $File -Parent)\$($ExpandedFileName)" -out $XMLFileName | Out-Null

                    if ($NodesToExclude) {
                        #Make a backup before removing nodes
                        $XMLFileName | Copy-Item -Destination $XMLFileName.Replace(".XML","_ORIG.XML")
                        [xml]$Content = Get-Content -Path $XMLFileName -Raw
                        $nodes = foreach ($nodeName in $NodesToExclude) {
                            if ($nodeName -eq "DEVICE_BLOCK") {
                                $Content.SelectNodes("//DEVICE_BLOCK") | where-object { $_.UPGRADE_DATA.'#text' -eq 0 }
                            }
                            else {
                                $Content.SelectNodes("//$nodeName")
                            }
                        }
                        foreach ($node in $nodes) {
                            $node.ParentNode.RemoveChild($node) | Out-Null
                        }
                        $Content.Save($XMLFileName)
                    }
                    Write-Host $Script:tick -ForegroundColor green
                }
            }
            else {
                Write-Warning "No SDB Files found at path: $($AppraiserDataPath)."
            }
        }
    }
    catch {
        Write-Warning $_
    }
}