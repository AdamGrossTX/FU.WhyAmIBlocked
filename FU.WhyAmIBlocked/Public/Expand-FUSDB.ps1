
#Converted from python https://github.com/TheEragon/SdbUnpacker
function Expand-FUSDB {
    [cmdletbinding()]
    param
    (
        [parameter(Mandatory = $false)]
        [string]
        $Path = $script:Config.Path,

        [parameter(Mandatory = $false)]
        [string]
        $InputFile,

        [parameter(Mandatory = $false)]
        [string]
        $OutputFile

    )

    try {
        
        $inFile = (Join-Path -Path $Path -ChildPath $InputFile)
        $outFile = (Join-Path -Path $Path -ChildPath $OutputFile)
        
        if (Test-Path $inFile -ErrorAction SilentlyContinue) {
            Write-Host " + Expanding $($Infile) to $($OutFile).. " -ForegroundColor Cyan -NoNewline
            $inFileBytes = [System.IO.File]::ReadAllBytes( $(resolve-path $InFile) )

            #Check for the zdbf header
            $SDBHeaderVal = "7A646266" #zdbf
            $FileTypeHeader = ($inFileBytes[8..11] | foreach-Object ToString X2) -join ''
            $DataSize = [bitconverter]::ToInt32($inFileBytes[16..19], 0)

            if ($FileTypeHeader -eq $SDBHeaderVal) {
                #Remove the first 20 bytes to get the zlib compressed file.
                #Remove the first 2 bytes of the zlib header to get the DeflateStream blob.
                $DeflateStreamBlob = $inFileBytes[22..($inFileBytes.Length)]
                $MemoryStream = New-Object System.IO.MemoryStream(, $DeflateStreamBlob)
                $OutputObj = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
                $DeflateStream = New-Object System.IO.Compression.DeflateStream $MemoryStream, ([IO.Compression.CompressionMode]::Decompress)
                
                $buffer = New-Object byte[](1024);
                while ($true) {
                    $read = $DeflateStream.Read($buffer, 0, 1024)
                    if ($read -le 0) {
                        break;
                    }
                    $OutputObj.Write($buffer, 0, $read)
                }

                if ($OutputObj.Length -eq $DataSize) {
                    Write-Host $Script:tick -ForegroundColor green
                }
                else {
                    throw "The expanded file size doesn't match the expected size. The file may be corrupt. Please try again."
                }
            }
            else {
                throw "Invalid SDB File speficied."
            }
        }
        else {
            throw "Could not find the specified inputfile $($inFile)"
        }
    }
    catch {
        Write-Warning $_
    }
    Finally {
        if ($DeflateStream) { $DeflateStream.Close() }
        if ($OutputObj) { $OutputObj.Close() }
    }
}