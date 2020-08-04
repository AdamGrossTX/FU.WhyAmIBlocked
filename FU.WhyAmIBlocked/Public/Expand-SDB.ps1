
Function Expand-SDB
{
    [cmdletbinding()]
    Param
    (
        [String]$InFile,
        [String]$OutFile
    )

    Try
    {
        Write-Host " + Converting sdb to xml.. " -ForegroundColor Cyan -NoNewline
        $bytes = [System.IO.File]::ReadAllBytes( $(resolve-path $InFile) )
        #Remove the first 20 bytes to get the zlib compressed file.
        #Remove the first 2 bytes of the zlib header to get the DeflateStream blob.
        $data = $Bytes[22..($bytes.Length)]
        $memoryStream = New-Object System.IO.MemoryStream(,$data)
        $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
        $DeflateStream = New-Object System.IO.Compression.DeflateStream $memoryStream, ([IO.Compression.CompressionMode]::Decompress)
        
        $buffer = New-Object byte[](1024);
        while($true)
        {
            $read = $DeflateStream.Read($buffer, 0, 1024)
            if ($read -le 0)
            {
                break;
            }
            $output.Write($buffer, 0, $read)
        }
        Write-Host $Script:tick -ForegroundColor green
    }
    Catch {
        Write-Warning $_
    }
    Finally
    {
         $DeflateStream.Close();
         $output.Close();
    }
}