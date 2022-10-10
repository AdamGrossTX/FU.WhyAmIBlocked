function Get-FUOSMap {
    param (
        $Content
    )
    try {
        $HWCOMPAT_SOURCE_INFO = $Content.SelectNodes("//HWCOMPAT_SOURCE_INFO")
        
        #th1 = "Threshold 1"
        #th2 = "Threshold 2"
        #rs1 = "Redstone 1"
        #rs2 = "Redstone 2"
        #rs3 = "Redstone 3"
        #rs4 = "Redstone 4"
        #rs5 = "Redstone 5"
        #19h1 = "19H1"
        #vb = "Vibranium"
        #co = "Cobalt, Sun Valley"
        #ni = "Nickel, Sun Valley 2"
        #cu = "Copper"

        $DestOSMap = foreach ($hw in $HWCOMPAT_SOURCE_INFO) {
            [pscustomobject] @{
                Name                = $hw.DEST_OS.'#text'
                Build               = ($hw.FILE_VERSION.'#text').Split('.')[0]
                BuildExt            = $hw.FILE_VERSION.'#text'
                HWCOMPAT_HWID_COUNT = $hw.HWCOMPAT_HWID_COUNT.'#text'
            }
        }
        return $DestOSMap
    }
    catch {
        throw $_
    }
}