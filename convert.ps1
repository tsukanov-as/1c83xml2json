$path = 'C:\temp\Config'
Remove-Item '*.zip'

function MultiLang ($nodes) {
    $map = @{}; foreach ($x in $nodes) {$map[$x.lang] = $x.Content}; $map
}

function SaveAsZippedJson ($list, $name) {
    $list | ConvertTo-Json -Depth 10 | Out-File "$name.json" -Encoding 'utf8'
    Compress-Archive -Path "$name.json" -DestinationPath "$name.zip" -Force
    Remove-Item "$name.json"
}

function ListOfNames ($items) {
    @(foreach ($x in $items) {$x.InnerText}) -join ","
}

function TypeValue ($node) {
    switch ($node.Type) {
        'v8:FixedArray' {
            $x = @()
            $node.ChildNodes | ForEach-Object {
                $x += TypeValue $_   
            }
            @{$node.Type = $x}
        }
        default {
            if ($node.Type) { @{$node.Type = $node.ChildNodes.Value} }
        }
    }
}

function Picture ($node) {
    @{'Ref' = $node.Ref; 'LoadTransparent' = $node.LoadTransparent}
}

function ChoiceParameters ($nodes) {
    $map = @{}
    foreach ($item in $nodes) {
        $map[$item.Attributes.Value] = TypeValue $item.ChildNodes
    }
    $map
}

function ChoiceParameterLinks ($nodes) {
    $map = @{}
    foreach ($item in $nodes) {
        $map[$item.Name] = @{
            DataPath = TypeValue $item.DataPath
            ValueChange = $item.ValueChange
        }        
    }
    $map
}

function StandardAttributes ($nodes) {
    $map = @{}
    foreach ($prop in $nodes) {
        $map[$prop.name] = @{
            LinkByType           = $prop.LinkByType
            FillChecking         = $prop.FillChecking
            MultiLine            = $prop.MultiLine
            FillFromFillingValue = $prop.FillFromFillingValue
            CreateOnInput        = $prop.CreateOnInput
            MaxValue             = TypeValue $prop.MaxValue
            ToolTip              = MultiLang $prop.ToolTip.ChildNodes
            ExtendedEdit         = $prop.ExtendedEdit
            Format               = MultiLang $prop.Format.ChildNodes
            ChoiceForm           = $prop.ChoiceForm
            QuickChoice          = $prop.QuickChoice
            ChoiceHistoryOnInput = $prop.ChoiceHistoryOnInput
            EditFormat           = MultiLang $prop.EditFormat.ChildNodes
            PasswordMode         = $prop.PasswordMode
            MarkNegatives        = $prop.MarkNegatives
            MinValue             = TypeValue $prop.MinValue
            Synonym              = MultiLang $prop.Synonym.ChildNodes
            Comment              = $prop.Comment
            FullTextSearch       = $prop.FullTextSearch
            ChoiceParameterLinks = ChoiceParameterLinks $prop.ChoiceParameterLinks.ChildNodes
            FillValue            = TypeValue $prop.FillValue
            Mask                 = $prop.Mask
            ChoiceParameters     = ChoiceParameters $prop.ChoiceParameters.ChildNodes
        }
    }
    $map
}

function ChildObjects ($nodes) {
    if (!$nodes) { return }
    $attributes = @{}
    $forms = @()
    $tabularSections = @{}
    $commands = @{}
    $templates = @()
    $dimensions = @{}
    $resources = @{}
    $enumvalues = @{}
    foreach ($obj in $nodes) {
        # $obj = $_
        switch ($obj.name) {
            'Attribute' {
                $prop = $obj.Properties
                $attributes[$prop.name] = @{
                    Synonym               = MultiLang $prop.Synonym.ChildNodes
                    Comment               = $prop.Comment
                    Type                  = ListOfNames $prop.Type.ChildNodes
                    PasswordMode          = $prop.PasswordMode
                    Format                = MultiLang $prop.Format.ChildNodes
                    EditFormat            = MultiLang $prop.EditFormat.ChildNodes
                    ToolTip               = MultiLang $prop.ToolTip.ChildNodes
                    MarkNegatives         = $prop.MarkNegatives
                    Mask                  = $prop.Mask
                    MultiLine             = $prop.MultiLine
                    ExtendedEdit          = $prop.ExtendedEdit
                    MinValue              = TypeValue $prop.MinValue
                    MaxValue              = TypeValue $prop.MaxValue
                    FillFromFillingValue  = $prop.FillFromFillingValue
                    FillValue             = TypeValue $prop.FillValue
                    FillChecking          = $prop.FillChecking
                    ChoiceFoldersAndItems = $prop.ChoiceFoldersAndItems
                    ChoiceParameterLinks  = ChoiceParameterLinks $prop.ChoiceParameterLinks.ChildNodes
                    ChoiceParameters      = ChoiceParameters $prop.ChoiceParameters.ChildNodes
                    QuickChoice           = $prop.QuickChoice 
                    CreateOnInput         = $prop.CreateOnInput
                    ChoiceForm            = $prop.ChoiceForm
                    LinkByType            = $prop.LinkByType
                    ChoiceHistoryOnInput  = $prop.ChoiceHistoryOnInput
                    Indexing              = $prop.Indexing
                    FullTextSearch        = $prop.FullTextSearch
                }
            }
            'Form' {
                $forms += $obj.ChildNodes.Value
            }
            'TabularSection' {
                $prop = $obj.Properties
                $tabularSections[$prop.name] = @{
                    Synonym            = MultiLang $prop.Synonym.ChildNodes
                    Comment            = $prop.Comment
                    ToolTip            = MultiLang $prop.ToolTip.ChildNodes
                    FillChecking       = $prop.FillChecking
                    StandardAttributes = StandardAttributes $prop.StandardAttributes.ChildNodes
                    ChildObjects       = ChildObjects $obj.ChildObjects.ChildNodes
                }
            }
            'Command' {
                $prop = $obj.Properties
                $commands[$prop.name] = @{
                    Synonym              = MultiLang $prop.Synonym.ChildNodes
                    Comment              = $prop.Comment
                    Group                = $prop.Group
                    CommandParameterType = ListOfNames $prop.CommandParameterType.ChildNodes
                    ParameterUseMode     = $prop.ParameterUseMode
                    ModifiesData         = $prop.ModifiesData
                    Representation       = $prop.Representation
                    ToolTip              = MultiLang $prop.ToolTip.ChildNodes
                    Picture              = Picture $prop.Picture
                    Shortcut             = $prop.Shortcut
                }
            }
            'Template' {
                $templates += $obj.ChildNodes.Value
            }
            'Dimension' {
                $prop = $obj.Properties
                $dimensions[$prop.name] = @{
                    Synonym               = MultiLang $prop.Synonym.ChildNodes
                    Comment               = $prop.Comment
                    Type                  = ListOfNames $prop.Type.ChildNodes
                    PasswordMode          = $prop.PasswordMode
                    Format                = MultiLang $prop.Format.ChildNodes
                    EditFormat            = MultiLang $prop.EditFormat.ChildNodes
                    ToolTip               = MultiLang $prop.ToolTip.ChildNodes
                    MarkNegatives         = $prop.MarkNegatives
                    Mask                  = $prop.Mask
                    MultiLine             = $prop.MultiLine
                    ExtendedEdit          = $prop.ExtendedEdit
                    MinValue              = TypeValue $prop.MinValue
                    MaxValue              = TypeValue $prop.MaxValue
                    FillFromFillingValue  = $prop.FillFromFillingValue
                    FillValue             = TypeValue $prop.FillValue
                    FillChecking          = $prop.FillChecking
                    ChoiceFoldersAndItems = $prop.ChoiceFoldersAndItems
                    ChoiceParameterLinks  = ChoiceParameterLinks $prop.ChoiceParameterLinks.ChildNodes
                    ChoiceParameters      = ChoiceParameters $prop.ChoiceParameters.ChildNodes
                    QuickChoice           = $prop.QuickChoice
                    CreateOnInput         = $prop.CreateOnInput
                    ChoiceForm            = $prop.ChoiceForm
                    LinkByType            = $prop.LinkByType
                    ChoiceHistoryOnInput  = $prop.ChoiceHistoryOnInput
                    Master                = $prop.Master
                    MainFilter            = $prop.MainFilter
                    DenyIncompleteValues  = $prop.DenyIncompleteValues
                    Indexing              = $prop.Indexing
                    FullTextSearch        = $prop.FullTextSearch
                    UseInTotals           = $prop.UseInTotals
                }
            }
            'Resource' {
                $prop = $obj.Properties
                $resources[$prop.name] = @{
                    Synonym               = MultiLang $prop.Synonym.ChildNodes
                    Comment               = $prop.Comment
                    Type                  = ListOfNames $prop.Type.ChildNodes
                    PasswordMode          = $prop.PasswordMode
                    Format                = MultiLang $prop.Format.ChildNodes
                    EditFormat            = MultiLang $prop.EditFormat.ChildNodes
                    ToolTip               = MultiLang $prop.ToolTip.ChildNodes
                    MarkNegatives         = $prop.MarkNegatives
                    Mask                  = $prop.Mask
                    MultiLine             = $prop.MultiLine
                    ExtendedEdit          = $prop.ExtendedEdit
                    MinValue              = TypeValue $prop.MinValue
                    MaxValue              = TypeValue $prop.MaxValue
                    FillFromFillingValue  = $prop.FillFromFillingValue
                    FillValue             = TypeValue $prop.FillValue
                    FillChecking          = $prop.FillChecking
                    ChoiceFoldersAndItems = $prop.ChoiceFoldersAndItems
                    ChoiceParameterLinks  = ChoiceParameterLinks $prop.ChoiceParameterLinks.ChildNodes
                    ChoiceParameters      = ChoiceParameters $prop.ChoiceParameters.ChildNodes
                    QuickChoice           = $prop.QuickChoice
                    CreateOnInput         = $prop.CreateOnInput
                    ChoiceForm            = $prop.ChoiceForm
                    LinkByType            = $prop.LinkByType
                    ChoiceHistoryOnInput  = $prop.ChoiceHistoryOnInput
                    Indexing              = $prop.Indexing
                    FullTextSearch        = $prop.FullTextSearch
                }
            }
            'EnumValue' {
                $prop = $obj.Properties
                $enumvalues[$prop.name] = @{
                    Synonym = MultiLang $prop.Synonym.ChildNodes
                    Comment = $prop.Comment
                }
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
    if ($enumvalues.Count -gt 0) {$result['EnumValues'] = $enumvalues}
    $result
}

#----------------------------------------------------------------------------------------------------------------------

$name = 'Documents'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.Document.Properties
    $list += @{
        Name                             = $prop.Name
        Synonym                          = MultiLang $prop.Synonym.ChildNodes
        Comment                          = $prop.Comment
        UseStandardCommands              = $prop.UseStandardCommands
        Numerator                        = $prop.Numerator
        NumberType                       = $prop.NumberType
        NumberLength                     = $prop.NumberLength
        NumberAllowedLength              = $prop.NumberAllowedLength
        NumberPeriodicity                = $prop.NumberPeriodicity
        CheckUnique                      = $prop.CheckUnique
        Autonumbering                    = $prop.Autonumbering
        StandardAttributes               = StandardAttributes $prop.StandardAttributes.ChildNodes
        # Characteristics                = $prop.Characteristics
        BasedOn                          = ListOfNames $prop.BasedOn.ChildNodes
        InputByString                    = ListOfNames $prop.InputByString.ChildNodes
        CreateOnInput                    = $prop.CreateOnInput
        SearchStringModeOnInputByString  = $prop.SearchStringModeOnInputByString
        FullTextSearchOnInputByString    = $prop.FullTextSearchOnInputByString
        ChoiceDataGetModeOnInputByString = $prop.ChoiceDataGetModeOnInputByString
        DefaultObjectForm                = $prop.DefaultObjectForm
        DefaultListForm                  = $prop.DefaultListForm
        DefaultChoiceForm                = $prop.DefaultChoiceForm
        AuxiliaryObjectForm              = $prop.AuxiliaryObjectForm
        AuxiliaryListForm                = $prop.AuxiliaryListForm
        AuxiliaryChoiceForm              = $prop.AuxiliaryChoiceForm
        Posting                          = $prop.Posting
        RealTimePosting                  = $prop.RealTimePosting
        RegisterRecordsDeletion          = $prop.RegisterRecordsDeletion
        RegisterRecordsWritingOnPost     = $prop.RegisterRecordsWritingOnPost
        SequenceFilling                  = $prop.SequenceFilling
        RegisterRecords                  = ListOfNames $prop.RegisterRecords.ChildNodes
        PostInPrivilegedMode             = $prop.PostInPrivilegedMode
        UnpostInPrivilegedMode           = $prop.UnpostInPrivilegedMode
        IncludeHelpInContents            = $prop.IncludeHelpInContents
        DataLockFields                   = ListOfNames $prop.DataLockFields.ChildNodes
        DataLockControlMode              = $prop.DataLockControlMode
        FullTextSearch                   = $prop.FullTextSearch
        ObjectPresentation               = MultiLang $prop.ObjectPresentation.ChildNodes
        ExtendedObjectPresentation       = MultiLang $prop.ExtendedObjectPresentation.ChildNodes
        ListPresentation                 = MultiLang $prop.ListPresentation.ChildNodes
        ExtendedListPresentation         = MultiLang $prop.ExtendedListPresentation.ChildNodes
        Explanation                      = MultiLang $prop.Explanation.ChildNodes
        ChoiceHistoryOnInput             = $prop.ChoiceHistoryOnInput
        ChildObjects                     = ChildObjects $data.MetaDataObject.Document.ChildObjects.ChildNodes
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'Catalogs'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.Catalog.Properties
    $list += @{
        Name                             = $prop.Name
        Synonym                          = MultiLang $prop.Synonym.ChildNodes
        Hierarchical                     = $prop.Hierarchical
        HierarchyType                    = $prop.HierarchyType
        LimitLevelCount                  = $prop.LimitLevelCount
        LevelCount                       = $prop.LevelCount
        FoldersOnTop                     = $prop.FoldersOnTop
        UseStandardCommands              = $prop.UseStandardCommands
        Owners                           = ListOfNames $prop.Owners.ChildNodes
        SubordinationUse                 = $prop.SubordinationUse
        CodeLength                       = $prop.CodeLength
        DescriptionLength                = $prop.DescriptionLength
        CodeType                         = $prop.CodeType
        CodeAllowedLength                = $prop.CodeAllowedLength
        CodeSeries                       = $prop.CodeSeries
        CheckUnique                      = $prop.CheckUnique
        Autonumbering                    = $prop.Autonumbering
        DefaultPresentation              = $prop.DefaultPresentation
        StandardAttributes               = StandardAttributes $prop.StandardAttributes.ChildNodes
        # Characteristics                = $prop.Characteristics
        PredefinedDataUpdate             = $prop.PredefinedDataUpdate
        EditType                         = $prop.EditType
        QuickChoice                      = $prop.QuickChoice
        ChoiceMode                       = $prop.ChoiceMode
        InputByString                    = ListOfNames $prop.InputByString.ChildNodes
        SearchStringModeOnInputByString  = $prop.SearchStringModeOnInputByString
        FullTextSearchOnInputByString    = $prop.FullTextSearchOnInputByString
        ChoiceDataGetModeOnInputByString = $prop.ChoiceDataGetModeOnInputByString
        DefaultObjectForm                = $prop.DefaultObjectForm
        DefaultFolderForm                = $prop.DefaultFolderForm
        DefaultListForm                  = $prop.DefaultListForm
        DefaultChoiceForm                = $prop.DefaultChoiceForm
        DefaultFolderChoiceForm          = $prop.DefaultFolderChoiceForm
        AuxiliaryObjectForm              = $prop.AuxiliaryObjectForm
        AuxiliaryFolderForm              = $prop.AuxiliaryFolderForm
        AuxiliaryListForm                = $prop.AuxiliaryListForm
        AuxiliaryChoiceForm              = $prop.AuxiliaryChoiceForm
        AuxiliaryFolderChoiceForm        = $prop.AuxiliaryFolderChoiceForm
        IncludeHelpInContents            = $prop.IncludeHelpInContents
        BasedOn                          = ListOfNames $prop.BasedOn.ChildNodes
        DataLockFields                   = ListOfNames $prop.DataLockFields.ChildNodes
        DataLockControlMode              = $prop.DataLockControlMode
        FullTextSearch                   = $prop.FullTextSearch
        ObjectPresentation               = MultiLang $prop.ObjectPresentation.ChildNodes
        ExtendedObjectPresentation       = MultiLang $prop.ExtendedObjectPresentation.ChildNodes
        ListPresentation                 = MultiLang $prop.ListPresentation.ChildNodes
        ExtendedListPresentation         = MultiLang $prop.ExtendedListPresentation.ChildNodes
        Explanation                      = MultiLang $prop.Explanation.ChildNodes
        CreateOnInput                    = $prop.CreateOnInput
        ChoiceHistoryOnInput             = $prop.ChoiceHistoryOnInput
        ChildObjects                     = ChildObjects $data.MetaDataObject.Catalog.ChildObjects.ChildNodes
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'AccumulationRegisters'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.AccumulationRegister.Properties
    $list += @{
        Name                     = $prop.Name
        Synonym                  = MultiLang $prop.Synonym.ChildNodes
        Comment                  = $prop.Comment
        UseStandardCommands      = $prop.UseStandardCommands
        DefaultListForm          = $prop.DefaultListForm
        AuxiliaryListForm        = $prop.AuxiliaryListForm
        RegisterType             = $prop.RegisterType
        IncludeHelpInContents    = $prop.IncludeHelpInContents
        StandardAttributes       = StandardAttributes $prop.StandardAttributes.ChildNodes
        DataLockControlMode      = $prop.DataLockControlMode
        FullTextSearch           = $prop.FullTextSearch
        EnableTotalsSplitting    = $prop.EnableTotalsSplitting
        ListPresentation         = MultiLang $prop.ListPresentation.ChildNodes
        ExtendedListPresentation = MultiLang $prop.ExtendedListPresentation.ChildNodes
        Explanation              = MultiLang $prop.Explanation.ChildNodes
        ChildObjects             = ChildObjects $data.MetaDataObject.AccumulationRegister.ChildObjects.ChildNodes
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'InformationRegisters'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.InformationRegister.Properties
    $list += @{
        Name                           = $prop.Name
        Synonym                        = MultiLang $prop.Synonym.ChildNodes
        Comment                        = $prop.Comment
        UseStandardCommands            = $prop.UseStandardCommands
        DefaultRecordForm              = $prop.DefaultRecordForm
        DefaultListForm                = $prop.DefaultListForm
        AuxiliaryRecordForm            = $prop.AuxiliaryRecordForm
        AuxiliaryListForm              = $prop.AuxiliaryListForm
        StandardAttributes             = StandardAttributes $prop.StandardAttributes.ChildNodes
        InformationRegisterPeriodicity = $prop.InformationRegisterPeriodicity
        WriteMode                      = $prop.WriteMode
        MainFilterOnPeriod             = $prop.MainFilterOnPeriod
        IncludeHelpInContents          = $prop.IncludeHelpInContents
        DataLockControlMode            = $prop.DataLockControlMode
        FullTextSearch                 = $prop.FullTextSearch
        EnableTotalsSliceFirst         = $prop.EnableTotalsSliceFirst
        EnableTotalsSliceLast          = $prop.EnableTotalsSliceLast
        RecordPresentation             = MultiLang $prop.RecordPresentation.ChildNodes
        ExtendedRecordPresentation     = MultiLang $prop.ExtendedRecordPresentation.ChildNodes
        ListPresentation               = MultiLang $prop.ListPresentation.ChildNodes
        ExtendedListPresentation       = MultiLang $prop.ExtendedListPresentation.ChildNodes
        Explanation                    = MultiLang $prop.Explanation.ChildNodes
        ChildObjects                   = ChildObjects $data.MetaDataObject.InformationRegister.ChildObjects.ChildNodes
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'Constants'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.Constant.Properties
    $list += @{
        Name                  = $prop.Name
        Synonym               = MultiLang $prop.Synonym.ChildNodes
        Comment               = $prop.Comment
        UseStandardCommands   = $prop.UseStandardCommands
        DefaultForm           = $prop.DefaultForm
        ExtendedPresentation  = MultiLang $prop.ExtendedPresentation.ChildNodes
        Explanation           = MultiLang $prop.Explanation.ChildNodes
        PasswordMode          = $prop.PasswordMode
        Format                = MultiLang $prop.Format.ChildNodes
        EditFormat            = MultiLang $prop.EditFormat.ChildNodes
        ToolTip               = MultiLang $prop.ToolTip.ChildNodes
        MarkNegatives         = $prop.MarkNegatives
        Mask                  = $prop.Mask
        MultiLine             = $prop.MultiLine
        ExtendedEdit          = $prop.ExtendedEdit
        MinValue              = TypeValue $prop.MinValue
        MaxValue              = TypeValue $prop.MaxValue
        FillChecking          = $prop.FillChecking
        ChoiceFoldersAndItems = $prop.ChoiceFoldersAndItems
        ChoiceParameterLinks  = ChoiceParameterLinks $prop.ChoiceParameterLinks.ChildNodes
        ChoiceParameters      = ChoiceParameters $prop.ChoiceParameters.ChildNodes
        QuickChoice           = $prop.QuickChoice
        ChoiceForm            = $prop.ChoiceForm
        LinkByType            = $prop.LinkByType
        ChoiceHistoryOnInput  = $prop.ChoiceHistoryOnInput
        DataLockControlMode   = $prop.DataLockControlMode
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'Enums'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.Enum.Properties
    $list += @{
        Name                     = $prop.Name
        Synonym                  = MultiLang $prop.Synonym.ChildNodes
        Comment                  = $prop.Comment
        UseStandardCommands      = $prop.UseStandardCommands
        # Characteristics        = $prop.Characteristics
        QuickChoice              = $prop.QuickChoice
        ChoiceMode               = $prop.ChoiceMode
        DefaultListForm          = $prop.DefaultListForm
        DefaultChoiceForm        = $prop.DefaultChoiceForm
        AuxiliaryListForm        = $prop.AuxiliaryListForm
        AuxiliaryChoiceForm      = $prop.AuxiliaryChoiceForm
        ListPresentation         = MultiLang $prop.ListPresentation.ChildNodes
        ExtendedListPresentation = MultiLang $prop.ExtendedListPresentation.ChildNodes
        Explanation              = MultiLang $prop.Explanation.ChildNodes
        ChoiceHistoryOnInput     = $prop.ChoiceHistoryOnInput
        ChildObjects             = ChildObjects $data.MetaDataObject.Enum.ChildObjects.ChildNodes
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'CommonCommands'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.CommonCommand.Properties
    $list += @{
        Name                  = $prop.Name
        Synonym               = MultiLang $prop.Synonym.ChildNodes
        Comment               = $prop.Comment
        Group                 = $prop.Group
        Representation        = $prop.Representation
        ToolTip               = MultiLang $prop.ToolTip.ChildNodes
        Picture               = Picture $prop.Picture
        Shortcut              = $prop.Shortcut
        IncludeHelpInContents = $prop.IncludeHelpInContents
        CommandParameterType  = ListOfNames $prop.CommandParameterType.ChildNodes
        ParameterUseMode      = $prop.ParameterUseMode
        ModifiesData          = $prop.ModifiesData
    } 
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'FunctionalOptions'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.FunctionalOption.Properties
    $list += @{
        Name              = $prop.Name
        Synonym           = MultiLang $prop.Synonym.ChildNodes
        Comment           = $prop.Comment
        Location          = $prop.Location
        PrivilegedGetMode = $prop.PrivilegedGetMode
        Content           = ListOfNames $prop.Content.ChildNodes
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'EventSubscriptions'
$list = @()

$files = Get-ChildItem "$path\$name" -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.EventSubscription.Properties
    $list += @{
        Name    = $prop.Name
        Synonym = MultiLang $prop.Synonym.ChildNodes
        Comment = $prop.Comment
        Source  = ListOfNames $prop.Source.ChildNodes
        Event   = $prop.Event
        Handler = $prop.Handler
    }
}

SaveAsZippedJson $list $name

#----------------------------------------------------------------------------------------------------------------------

$name = 'Roles'
$list = @()

$directory = "$path\$name"

$files = Get-ChildItem $directory -Filter *.xml
foreach ($file in $files) {
    [xml]$data = Get-Content $file.FullName
    $prop = $data.MetaDataObject.Role.Properties
    $list += @{
        Name = $prop.Name
        Synonym = MultiLang $prop.Synonym.ChildNodes
        Comment = $prop.Comment
    }
}

SaveAsZippedJson $list $name

$name = 'Rights'
$table = @{}

foreach ($prop in $list) {
    $role = $prop.Name
    [xml]$rights = Get-Content "$directory\$role\Ext\$name.xml"
    $rights.Rights.object | ForEach-Object {
        if ($_) {
            $x = $table[$_.Name]
            if (!$x) {$x = @{}; $table.Add($_.Name, $x)}
            $_.Right | ForEach-Object {
                if ($_.value -eq 'true') {
                    $x[$_.name] += ,$role
                }
            }
        }
    }
    $delist = @()
    foreach ($key in $table.Keys) {
        if ($table[$key].Count -eq 0) {$delist += $key}
    }
    foreach ($key in $delist) {
        $table.Remove($key)
    }
}

SaveAsZippedJson $table $name