
    $Public = @(Get-ChildItem -Path "$($PSScriptRoot)\Public\*.ps1" -ErrorAction SilentlyContinue)
    $Private = @(Get-ChildItem -Path "$($PSScriptRoot)\Private\*.ps1" -ErrorAction SilentlyContinue)
    $script:Prefix = "fu"
    $script:Path = "C:\FeatureUpdateBlocks"
    $initCfg = @{
        Path = "$($script:Path)"
        ConfigFile = "$($script:Path)\Config.json"
        SDBCab = "Appraiser_AlternateData.cab"
        SDBUnPackerFile = Join-Path -Path $PSScriptRoot -ChildPath "SDBUnpacker.py"
        sdb2xmlPath = Join-Path -Path $PSScriptRoot -ChildPath "sdb2xml.exe"
        UserConfigFile = "$($env:USERPROFILE)\.$($script:Prefix)cfgpath"
    }
    $cfg = Get-Content $initCfg["UserConfigFile"] -ErrorAction SilentlyContinue
    $script:tick = [char]0x221a

    if ($cfg) {
        if (Get-Content -Path $cfg -raw -ErrorAction SilentlyContinue) {
            $script:Config = Get-Content -Path $cfg -raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        }
        else {
            $script:Config = $initCfg
        }
    }
    else {
        $script:Config = $initCfg
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

    Try {
        $pythonVersion = & python --version
    }
    Catch {
        Write-Host "Python is not installed. Install Pyton before proceeding." -foregroundColor Red
    }
    If($pythonVersion) {
        [switch]$script:PythonInstalled = $true
    }


