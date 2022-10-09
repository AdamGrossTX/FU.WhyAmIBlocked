function Get-FUXMLValuesFromTree {
    [cmdletbinding()]
    param (
        $node,
        [System.Collections.ArrayList]$Output
    )
    try {
        $obj = $node | Where-Object { $_.Name -ne '#text' -and !([string]::IsNullOrEmpty($_.'#text')) } | Select-Object Name, @{N = 'Value'; E = { $_.'#text' } }, ParentNode
        if ($obj) {
            $Object = [PSCustomObject]@{
                Name       = $obj.Name
                Value      = $obj.Value
                ParentNode = $obj.ParentNode.SchemaInfo.Name
            }
            if ($Output) {
                $Output += $Object
            }
            else {
                $Output = @($Object)
            }
        }
        if ($Node.HasChildNodes) {
            foreach ($ChildNode in $Node.ChildNodes) {
                $return = Get-FUXMLValuesFromTree -node $ChildNode -Output $Output
                if ($return) {
                    if ($return -is [PSCustomObject]) {
                        $Output = @($return)
                    }
                    else {
                        $Output = $return
                    }
                }
            }
        }
        return $Output
    }
    catch {
        Write-Warning $_
    }
}