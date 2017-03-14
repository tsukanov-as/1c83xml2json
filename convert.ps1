$path = 'C:\temp\Config'

function MultiLang ($nodes) {
    $map = @{}; $nodes | Sort-Object -Property lang | % {$map[$_.lang] = $_.Content}; $map
}

function SaveAsZippedJson ($list, $name) {
    $list | ConvertTo-Json -Depth 2 | Out-File "$name.json" -Encoding 'utf8'
    Compress-Archive -Path "$name.json" -DestinationPath "$name.zip" -Force
    Remove-Item "$name.json"
}

#----------------------------------------------------------------------------------------------------------------------

$name = 'Documents'
$list = @()

Get-ChildItem "$path\$name" -Filter *.xml | % {
    [xml]$data = Get-Content $_.FullName
    $prop = $data.MetaDataObject.Document.Properties
    $list += $prop |
    select `
        Name,
        @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
        Posting,
        RealTimePosting,
        RegisterRecordsDeletion,
        RegisterRecordsWritingOnPost 
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'Catalogs'
$list = @()

Get-ChildItem "$path\$name" -Filter *.xml | % {
    [xml]$data = Get-Content $_.FullName
    $prop = $data.MetaDataObject.Catalog.Properties
    $list += $prop |
    select `
        Name,
        @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
        Hierarchical,
        HierarchyType,
        LimitLevelCount
}

SaveAsZippedJson $list $name
