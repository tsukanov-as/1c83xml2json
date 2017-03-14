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
        Comment,
        UseStandardCommands,
        # Numerator,
        NumberType,
        NumberLength,
        NumberAllowedLength,
        NumberPeriodicity,
        CheckUnique,
        Autonumbering,
        # StandardAttributes,
        # Characteristics,
        # BasedOn,
        # InputByString,
        CreateOnInput,
        SearchStringModeOnInputByString,
        FullTextSearchOnInputByString,
        ChoiceDataGetModeOnInputByString,
        DefaultObjectForm,
        DefaultListForm,
        DefaultChoiceForm,
        AuxiliaryObjectForm,
        AuxiliaryListForm,
        AuxiliaryChoiceForm,
        Posting,
        RealTimePosting,
        RegisterRecordsDeletion,
        RegisterRecordsWritingOnPost,
        SequenceFilling,
        # RegisterRecords,
        PostInPrivilegedMode,
        UnpostInPrivilegedMode,
        IncludeHelpInContents,
        # DataLockFields,
        DataLockControlMode,
        FullTextSearch,
        @{Name='ObjectPresentation'; Expression={MultiLang $prop.ObjectPresentation.ChildNodes}},
        @{Name='ExtendedObjectPresentation'; Expression={MultiLang $prop.ExtendedObjectPresentation.ChildNodes}},
        @{Name='ListPresentation'; Expression={MultiLang $prop.ListPresentation.ChildNodes}},
        @{Name='ExtendedListPresentation'; Expression={MultiLang $prop.ExtendedListPresentation.ChildNodes}},
        @{Name='Explanation'; Expression={MultiLang $prop.Explanation.ChildNodes}},
        ChoiceHistoryOnInput
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
