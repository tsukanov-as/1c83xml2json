$path = 'C:\temp\Config'
Remove-Item '*.zip'

function MultiLang ($nodes) {
    $map = @{}; $nodes | Sort-Object -Property lang | ForEach-Object {$map[$_.lang] = $_.Content}; $map
}

function SaveAsZippedJson ($list, $name) {
    $list | ConvertTo-Json -Depth 5 | Out-File "$name.json" -Encoding 'utf8'
    Compress-Archive -Path "$name.json" -DestinationPath "$name.zip" -Force
    Remove-Item "$name.json"
}

function ListOfNames ($items) {
    $list = @(); $items | Sort-Object -Property InnerText | ForEach-Object {$list += $_.InnerText}; $list -join ","
}

function TypeValue ($node) {
    @{$node.Type = $node.ChildNodes.Value}
}

function Picture ($node) {
    @{'Ref' = $node.Ref; 'LoadTransparent' = $node.LoadTransparent}
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

function ChildObjects ($nodes) {
    $attributes = @{}
    $forms = @()
    $tabularSections = @{}
    $commands = @{}
    $templates = @()
    $dimensions = @{}
    $resources = @{}
    $nodes | ForEach-Object {
        $obj = $_
        switch ($obj.name) {
            'Attribute' {
                $prop = $obj.Properties
                $attributes[$prop.name] = $prop | Select-Object `
                    @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
                    Comment,
                    @{Name='Type'; Expression={ListOfNames $prop.Type.ChildNodes}},
                    PasswordMode,
                    Format,
                    EditFormat,
                    @{Name='ToolTip'; Expression={MultiLang $prop.ToolTip.ChildNodes}},
                    MarkNegatives,
                    Mask,
                    MultiLine,
                    ExtendedEdit,
                    @{Name='MinValue'; Expression={TypeValue $prop.MinValue}},
                    @{Name='MaxValue'; Expression={TypeValue $prop.MaxValue}},
                    FillFromFillingValue,
                    @{Name='FillValue'; Expression={TypeValue $prop.FillValue}},
                    FillChecking,
                    ChoiceFoldersAndItems,
                    ChoiceParameterLinks,
                    ChoiceParameters,
                    QuickChoice,
                    CreateOnInput,
                    ChoiceForm,
                    LinkByType,
                    ChoiceHistoryOnInput,
                    Indexing,
                    FullTextSearch
            }
            'Form' {
                $forms += $obj.ChildNodes.Value
            }
            'TabularSection' {
                $prop = $obj.Properties
                $tabularSections[$prop.name] = $prop | Select-Object `
                    @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
                    Comment,
                    @{Name='ToolTip'; Expression={MultiLang $prop.ToolTip.ChildNodes}},
                    FillChecking,
                    @{Name='StandardAttributes'; Expression={StandardAttributes $prop.StandardAttributes.ChildNodes}},
                    @{Name='ChildObjects'; Expression={ChildObjects $obj.ChildObjects.ChildNodes}}
            }
            'Command' {
                $prop = $obj.Properties
                $commands[$prop.name] = $prop | Select-Object `
                    @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
                    Comment,
                    Group,
                    @{Name='CommandParameterType'; Expression={ListOfNames $prop.CommandParameterType.ChildNodes}},
                    ParameterUseMode,
                    ModifiesData,
                    Representation,
                    @{Name='ToolTip'; Expression={MultiLang $prop.ToolTip.ChildNodes}},
                    @{Name='Picture'; Expression={Picture $prop.Picture}},
                    Shortcut
            }
            'Template' {
                $templates += $obj.ChildNodes.Value
            }
            'Dimension' {
                $prop = $obj.Properties
                $dimensions[$prop.name] = $prop | Select-Object `
                    @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
                    Comment,
                    @{Name='Type'; Expression={ListOfNames $prop.Type.ChildNodes}},
                    PasswordMode,
                    Format,
                    EditFormat,
                    @{Name='ToolTip'; Expression={MultiLang $prop.ToolTip.ChildNodes}},
                    MarkNegatives,
                    Mask,
                    MultiLine,
                    ExtendedEdit,
                    @{Name='MinValue'; Expression={TypeValue $prop.MinValue}},
                    @{Name='MaxValue'; Expression={TypeValue $prop.MaxValue}},
                    FillChecking,
                    ChoiceFoldersAndItems,
                    ChoiceParameterLinks,
                    ChoiceParameters,
                    QuickChoice,
                    CreateOnInput,
                    ChoiceForm,
                    LinkByType,
                    ChoiceHistoryOnInput,
                    DenyIncompleteValues,
                    Indexing,
                    FullTextSearch,
                    UseInTotals
            }
            'Resource' {
                $prop = $obj.Properties
                $resources[$prop.name] = $prop | Select-Object `
                    @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
                    Comment,
                    @{Name='Type'; Expression={ListOfNames $prop.Type.ChildNodes}},
                    PasswordMode,
                    Format,
                    EditFormat,
                    @{Name='ToolTip'; Expression={MultiLang $prop.ToolTip.ChildNodes}},
                    MarkNegatives,
                    Mask,
                    MultiLine,
                    ExtendedEdit,
                    @{Name='MinValue'; Expression={TypeValue $prop.MinValue}},
                    @{Name='MaxValue'; Expression={TypeValue $prop.MaxValue}},
                    FillChecking,
                    ChoiceFoldersAndItems,
                    ChoiceParameterLinks,
                    ChoiceParameters,
                    QuickChoice,
                    CreateOnInput,
                    ChoiceForm,
                    LinkByType,
                    ChoiceHistoryOnInput,
                    FullTextSearch
            }
            default {Write-Host $_}
        }
    }
    $result = @{}
    if ($attributes.Count -gt 0) {$result['Attributes'] = $attributes}
    if ($forms.Count -gt 0) {$result['Forms'] = $forms}
    if ($tabularSections.Count -gt 0) {$result['TabularSections'] = $tabularSections}
    if ($commands.Count -gt 0) {$result['Commands'] = $commands}
    if ($templates.Count -gt 0) {$result['Templates'] = $templates}
    if ($dimensions.Count -gt 0) {$result['Dimensions'] = $dimensions}
    if ($resources.Count -gt 0) {$result['Resources'] = $resources}
    $result
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
        ChoiceHistoryOnInput,
        @{Name='ChildObjects'; Expression={ChildObjects $data.MetaDataObject.Document.ChildObjects.ChildNodes}}
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
        ChoiceHistoryOnInput,
        @{Name='ChildObjects'; Expression={ChildObjects $data.MetaDataObject.Catalog.ChildObjects.ChildNodes}}
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'AccumulationRegisters'
$list = @()

Get-ChildItem "$path\$name" -Filter *.xml | ForEach-Object {
    [xml]$data = Get-Content $_.FullName
    $prop = $data.MetaDataObject.AccumulationRegister.Properties
    $list += $prop |
    Select-Object `
        Name,
        @{Name='Synonym'; Expression={MultiLang $prop.Synonym.ChildNodes}},
        Comment,
        UseStandardCommands,
        DefaultListForm,
        AuxiliaryListForm,
        RegisterType,
        IncludeHelpInContents,
        @{Name='StandardAttributes'; Expression={StandardAttributes $prop.StandardAttributes.ChildNodes}},
        DataLockControlMode,
        FullTextSearch,
        EnableTotalsSplitting,
        @{Name='ListPresentation'; Expression={MultiLang $prop.ListPresentation.ChildNodes}},
        @{Name='ExtendedListPresentation'; Expression={MultiLang $prop.ExtendedListPresentation.ChildNodes}},
        @{Name='Explanation'; Expression={MultiLang $prop.Explanation.ChildNodes}},
        @{Name='ChildObjects'; Expression={ChildObjects $data.MetaDataObject.AccumulationRegister.ChildObjects.ChildNodes}}
}

SaveAsZippedJson $list $name
