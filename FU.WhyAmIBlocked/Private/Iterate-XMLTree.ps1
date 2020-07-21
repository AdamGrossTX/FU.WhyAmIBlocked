Function IterateXMLTree{
    [cmdletbinding()]
    Param ( 
        $node
    )
    $obj = $node | Where-Object {$_.Name -ne '#text' -and !([string]::IsNullOrEmpty($_.'#text'))} | Select Name, @{N='Value';E={$_.'#text'}}, ParentNode
    If($obj) {
        $OutputObject = [PSCustomObject]@{
            Name = $obj.Name
            Value = $obj.Value
            ParentNode = $obj.ParentNode
        }
    }

    If($Node.HasChildNodes) {
        ForEach($ChildNode in $Node.ChildNodes) {
            IterateXMLTree -node $ChildNode
        }
    }
    Else {
        Return $OutputObject
    }
}