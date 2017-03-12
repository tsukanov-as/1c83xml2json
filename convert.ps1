$path = 'C:\temp\Config'

$list = @()

Get-ChildItem "$path\Documents" -Filter *.xml |
Foreach-Object {
    [xml]$Data = Get-Content $_.FullName
    $Prop = $Data.MetaDataObject.Document.Properties
    $Synonyms = $Prop.Synonym.ChildNodes 
    $SynonymEn = $Synonyms.Where{$_.lang -eq 'en'}
    $SynonymRu = $Synonyms.Where{$_.lang -eq 'ru'}
    $obj = @{}
    $obj.Name = $Prop.Name
    $obj.Synonym = @{en=$SynonymEn.Content;ru=$SynonymRu.Content}
    $obj.Posting = $Prop.Posting
    $obj.RealTimePosting = $Prop.RealTimePosting
    $obj.RegisterRecordsDeletion = $Prop.RegisterRecordsDeletion
    $obj.RegisterRecordsWritingOnPost = $Prop.RegisterRecordsWritingOnPost
    $list += $obj 
}

$list | ConvertTo-Json -Depth 2 | Out-File Documents.json -Encoding 'utf8'
Compress-Archive -Path Documents.json -DestinationPath Documents.zip -Force
Remove-Item Documents.json
