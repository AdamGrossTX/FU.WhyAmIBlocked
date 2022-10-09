function Get-FUBinFiles {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $DeviceName,
    
        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $Path,

        [parameter(Position = 3, Mandatory = $false)]
        [string]
        $DestinationPath
    )
    try {
        Write-Host " + Getting .bin files.. " -ForegroundColor Cyan -NoNewline
        Copy-Item -Path "$($Path)\*.bin" -Destination $DestinationPath\ -Container -Force -ErrorAction SilentlyContinue
        $BinFiles = (Get-Item -Path "$($DestinationPath)\*.bin" -ErrorAction SilentlyContinue).FullName
        Write-Host $script:tick -ForegroundColor Green
    
        return $BinFiles
    }
    catch {
        Write-Warning $_
    }
}