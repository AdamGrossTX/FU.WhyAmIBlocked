Function IterateXMLTree{
    [cmdletbinding()]
    Param (
        $node,
        [System.Collections.ArrayList]$Output
    )
    Try {
        $obj = $node | Where-Object {$_.Name -ne '#text' -and !([string]::IsNullOrEmpty($_.'#text'))} | Select-Object Name, @{N='Value';E={$_.'#text'}}, ParentNode
        If($obj) {
            $Object = [PSCustomObject]@{
                Name = $obj.Name
                Value = $obj.Value
                ParentNode = $obj.ParentNode.SchemaInfo.Name
            }
            If($Output) {
                $Output += $Object
            }
            Else {
                $Output = @($Object)
            }
        }
        If($Node.HasChildNodes) {
            ForEach($ChildNode in $Node.ChildNodes) {
                $Return = IterateXMLTree -node $ChildNode -Output $Output
                If($Return) {
                    If($Return -is [PSCustomObject]) {
                        $Output = @($Return)
                    }
                    Else {
                        $Output = $Return
                    }
                }
            }
        }
        Return $Output
    }
    Catch {
        Write-Warning $_
    }
}