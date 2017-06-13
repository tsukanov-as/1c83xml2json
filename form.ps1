function Multilingual ($nodes) {
    $map = @{}
    foreach ($x in $nodes) { $map[$x.Lang] = $x.Content}
    If ($map.Count -ne 0) { $map } else {$null}
}

function GetItems ($Parent) {
    $Items = @()
    If ($Parent.ChildNodes) {
        foreach ($Item In $Parent.ChildNodes) {
            $Items += @{
                Kind       = $Item.LocalName
                Name       = $Item.Name
                Title      = Multilingual $Item.Title.ChildNodes
                ShowTitle  = $Item.ShowTitle
                DataPath   = $Item.DataPath
                ChildItems = GetItems($Item.ChildItems)
            }
        }
    }
    If ($Items.Count -ne 0) { $Items } else {$null}
}

[xml]$Data = Get-Content $args[0]

$Items = GetItems($Data.Form.ChildItems)

$Items | ConvertTo-Json -Depth 10 | Out-File "form.json" -Encoding 'utf8'
