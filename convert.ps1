$path = 'C:\temp\Config'

#----------------------------------------------------------------------------------------------------------------------

$list = @()

Get-ChildItem "$path\Documents" -Filter *.xml | % {
    
    [xml]$Data = Get-Content $_.FullName
    
    $Prop = $Data.MetaDataObject.Document.Properties
    
    $Synonyms = $Prop.Synonym.ChildNodes 
    $SynonymEn = $Synonyms.Where{$_.lang -eq 'en'}
    $SynonymRu = $Synonyms.Where{$_.lang -eq 'ru'}
    
    $list += $Prop |
    select `
        Name,
        @{Name="Synonym";Expression={@{en=$SynonymEn.Content;ru=$SynonymRu.Content}}},
        Posting,
        RealTimePosting,
        RegisterRecordsDeletion,
        RegisterRecordsWritingOnPost 
}

$list | ConvertTo-Json -Depth 2 | Out-File Documents.json -Encoding 'utf8'
Compress-Archive -Path Documents.json -DestinationPath Documents.zip -Force
Remove-Item Documents.json

#----------------------------------------------------------------------------------------------------------------------

$list = @()

Get-ChildItem "$path\Catalogs" -Filter *.xml | % {
    
    [xml]$Data = Get-Content $_.FullName
    
    $Prop = $Data.MetaDataObject.Catalog.Properties
    
    $Synonyms = $Prop.Synonym.ChildNodes 
    $SynonymEn = $Synonyms.Where{$_.lang -eq 'en'}
    $SynonymRu = $Synonyms.Where{$_.lang -eq 'ru'}

    $list += $Prop |
    select `
        Name,
        @{Name="Synonym";Expression={@{en=$SynonymEn.Content;ru=$SynonymRu.Content}}},
        Hierarchical,
        HierarchyType,
        LimitLevelCount
}

$list | ConvertTo-Json -Depth 2 | Out-File Catalogs.json -Encoding 'utf8'
Compress-Archive -Path Catalogs.json -DestinationPath Catalogs.zip -Force
Remove-Item Catalogs.json
