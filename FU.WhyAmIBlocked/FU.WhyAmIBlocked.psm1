
    $Public = @(Get-ChildItem -Path $($PSScriptRoot)\Public\*.ps1 -ErrorAction SilentlyContinue)
    $Private = @(Get-ChildItem -Path $($PSScriptRoot)\Private\*.ps1 -ErrorAction SilentlyContinue)
    $Prefix = "fu"
    $cfg = Get-Content "$($env:USERPROFILE)\.fucfgpath" -ErrorAction SilentlyContinue
    $script:tick = [char]0x221a

    if ($cfg) {
        $script:fuConfig = if (Get-Content -Path $cfg -raw -ErrorAction SilentlyContinue) {
            Get-Content -Path $cfg -raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        }
        else {
            $script:fuConfig = $null
        }
    }
    #endregion
    #region Dot source the files
    foreach ($import in @($Public + $Private)) {
        try {
            . $import.FullName
        }
        catch {
            Write-Error -Message "Failed to import function $($import.FullName): $_"
        }
    }
    #endregion

