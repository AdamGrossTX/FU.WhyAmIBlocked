function Get-PythonVersion {
    [cmdletbinding()]
    Param()
    Try {
        If($Script:Config.PythonPath) {
            $PythonVersion = & $($Script:Config.PythonPath)\python.exe --version
        }
        Else {
            $PythonVersion = & python --version
        }
        Return $PythonVersion
    }
    Catch {
        Return $null
    }
}