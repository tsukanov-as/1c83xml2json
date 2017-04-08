$path = 'C:\temp\Config'
Remove-Item '*.zip'

function MultiLang ($nodes) {
    $map = @{}; $nodes | Sort-Object -Property lang | ForEach-Object {$map[$_.lang] = $_.Content}; $map
}

function SaveAsZippedJson ($list, $name) {
    $list | ConvertTo-Json -Depth 4 | Out-File "$name.json" -Encoding 'utf8'
    Compress-Archive -Path "$name.json" -DestinationPath "$name.zip" -Force
    Remove-Item "$name.json"
}

function ListOfNames ($items) {
    $list = @(); $items | Sort-Object -Property InnerText | ForEach-Object {$list += $_.InnerText}; $list -join ","
}

function TypeValue ($node) {
    @{$node.Type = $Node.ChildNodes.Value}
}

function StandardAttributes ($nodes) {
    $map = @{}
    $nodes | ForEach-Object {
        $map[$_.name] = $_ | Select-Object `
            LinkByType,
            FillChecking,
            MultiLine,
            FillFromFillingValue,
            CreateOnInput,
            @{Name='MaxValue'; Expression={TypeValue $_.MaxValue}},
            @{Name='ToolTip'; Expression={MultiLang $_.ToolTip.ChildNodes}},
            ExtendedEdit,
            Format,
            ChoiceForm,
            QuickChoice,
            ChoiceHistoryOnInput,
            EditFormat,
            PasswordMode,
            MarkNegatives,
            @{Name='MinValue'; Expression={TypeValue $_.MinValue}},
            @{Name='Synonym'; Expression={MultiLang $_.Synonym.ChildNodes}},
            Comment,
            FullTextSearch,
            ChoiceParameterLinks,
            @{Name='FillValue'; Expression={TypeValue $_.FillValue}},
            Mask,
            ChoiceParameters
    }
    $map
}

#----------------------------------------------------------------------------------------------------------------------

$name = 'Documents'
$list = @()

Get-ChildItem "$path\$name" -Filter *.xml | ForEach-Object {
    [xml]$data = Get-Content $_.FullName
    $prop = $data.MetaDataObject.Document.Properties
    $list += $prop |
    Select-Object `
        Name,
        @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
        Comment,
        UseStandardCommands,
        Numerator,
        NumberType,
        NumberLength,
        NumberAllowedLength,
        NumberPeriodicity,
        CheckUnique,
        Autonumbering,
        @{Name='StandardAttributes'; Expression={StandardAttributes $prop.StandardAttributes.ChildNodes}},
        # Characteristics,
        @{Name='BasedOn'; Expression={ListOfNames $prop.BasedOn.ChildNodes}},
        @{Name='InputByString'; Expression={ListOfNames $prop.InputByString.ChildNodes}},
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
        @{Name='RegisterRecords'; Expression={ListOfNames $prop.RegisterRecords.ChildNodes}},
        PostInPrivilegedMode,
        UnpostInPrivilegedMode,
        IncludeHelpInContents,
        @{Name='DataLockFields'; Expression={ListOfNames $prop.DataLockFields.ChildNodes}},
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

Get-ChildItem "$path\$name" -Filter *.xml | ForEach-Object {
    [xml]$data = Get-Content $_.FullName
    $prop = $data.MetaDataObject.Catalog.Properties
    $list += $prop |
    Select-Object `
        Name,
        @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
        Hierarchical,
        HierarchyType,
        LimitLevelCount,
        LevelCount,
        FoldersOnTop,
        UseStandardCommands,
        @{Name='Owners'; Expression={ListOfNames $prop.Owners.ChildNodes}},
        SubordinationUse,
        CodeLength,
        DescriptionLength,
        CodeType,
        CodeAllowedLength,
        CodeSeries,
        CheckUnique,
        Autonumbering,
        DefaultPresentation,
        @{Name='StandardAttributes'; Expression={StandardAttributes $prop.StandardAttributes.ChildNodes}},
        # Characteristics,
        PredefinedDataUpdate,
        EditType,
        QuickChoice,
        ChoiceMode,
        @{Name='InputByString'; Expression={ListOfNames $prop.InputByString.ChildNodes}},
        SearchStringModeOnInputByString,
        FullTextSearchOnInputByString,
        ChoiceDataGetModeOnInputByString,
        DefaultObjectForm,
        DefaultFolderForm,
        DefaultListForm,
        DefaultChoiceForm,
        DefaultFolderChoiceForm,
        AuxiliaryObjectForm,
        AuxiliaryFolderForm,
        AuxiliaryListForm,
        AuxiliaryChoiceForm,
        AuxiliaryFolderChoiceForm,
        IncludeHelpInContents,
        @{Name='BasedOn'; Expression={ListOfNames $prop.BasedOn.ChildNodes}},
        @{Name='DataLockFields'; Expression={ListOfNames $prop.DataLockFields.ChildNodes}},
        DataLockControlMode,
        FullTextSearch,
        @{Name='ObjectPresentation'; Expression={MultiLang $prop.ObjectPresentation.ChildNodes}},
        @{Name='ExtendedObjectPresentation'; Expression={MultiLang $prop.ExtendedObjectPresentation.ChildNodes}},
        @{Name='ListPresentation'; Expression={MultiLang $prop.ListPresentation.ChildNodes}},
        @{Name='ExtendedListPresentation'; Expression={MultiLang $prop.ExtendedListPresentation.ChildNodes}},
        @{Name='Explanation'; Expression={MultiLang $prop.Explanation.ChildNodes}},
        CreateOnInput,
        ChoiceHistoryOnInput
}

SaveAsZippedJson $list $name
