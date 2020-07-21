Function Get-BinFiles {
    [cmdletbinding()]
    Param (
        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $DeviceName,
    
        [parameter(Position = 2, Mandatory = $false)]
        [string]
        $Path
    )
        Try {
            If(!($Path)) {
                If($DeviceName) {
                    $Path = "\\$($DeviceName)\c`$\Windows\appcompat\appraiser\*.bin"
                }
                Else {
                    $Path = "C:\Windows\appcompat\appraiser\*.bin"
                }
            }
            $BinFiles = Get-Item -Path $Path -ErrorAction SilentlyContinue
    
            Return $BinFiles
        }
        Catch {
            $Error[0]
        }
}