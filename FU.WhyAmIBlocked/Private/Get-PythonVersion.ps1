function Get-PythonVersion {
    [cmdletbinding()]
    Param()
    Try {
        $PythonVersion = & python --version
        Return $PythonVersion
    }
    Catch {
        Return $null
    }
}