#run first chunk as domain admin on your laptop

#run this first
$batchName = Get-Date -Format MMddyy
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$fileName = "migrationbatchUPN"

#then run this
$file = "$desktopPath\$fileName.csv"
$inputCsv = Import-Csv $file | Sort-Object * -Unique

$exists = Test-Path -path "$desktopPath\sharegateBatch*.csv"
if ($exists) {
    Remove-Item -Path "$desktopPath\sharegateBatch*.csv" -Verbose
}
#US Create csv file with drives
#replace pathname with proper fileserver and drive name as needed
foreach ($user in $inputCsv.UPN) {
       $ADUser = Get-ADUser $user
       
       $last,$first = $ADUser.name -split " "
       $pathName = "\\server\e$\$first $last"
       
       $hash = [ordered]@{ DIRECTORY = "$pathName" ; ONEDRIVEURL = "https://contoso-my.sharepoint.com/personal/$($user)contoso/"}
       $newRow = new-object psobject -prop $hash

       Export-Csv -Path "$desktopPath\sharegateBatch$batchName.csv" -inputobject $newrow -append -NoTypeInformation -Force

       Write-Host "$user added to csv"
}

#run on USPGAP051
#Full upload
Import-Module Sharegate
$csvFile = "C:\Users\account\Desktop\sharegateBatch.csv"
$table = Import-Csv $csvFile -Delimiter ","
$mypassword = ConvertTo-SecureString "password" -AsPlainText -Force
Set-Variable dstSite, dstList
foreach ($row in $table) {
    Clear-Variable dstSite
    Clear-Variable dstList
    $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username "account@contoso.net" -Password $mypassword
    $dstList = Get-List -Name Documents -Site $dstSite
    Write-Output $dstlist
    Import-Document -SourceFilePath $row.DIRECTORY -DestinationList $dstList -DestinationFolder "M365ImportedPersonalFolder"
}


#for incremental: 
$copysettings = New-CopySettings -OnContentItemExists IncrementalUpdate
Import-Module Sharegate
$csvFile = "C:\Users\account\Desktop\sharegateBatch.csv"
$table = Import-Csv $csvFile -Delimiter ","
$mypassword = ConvertTo-SecureString "Password" -AsPlainText -Force
Set-Variable dstSite, dstList
foreach ($row in $table) {
    Clear-Variable dstSite
    Clear-Variable dstList
    $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username "account@contoso.net" -Password $mypassword
    $dstList = Get-List -Name Documents -Site $dstSite
    Write-Output $dstlist
    Import-Document -SourceFilePath $row.DIRECTORY -DestinationList $dstList -DestinationFolder "M365ImportedPersonalFolder" -CopySettings $copysettings

    #Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList -DestinationFolder "M365ImportedPersonalFolder"
}


#test/quickfix
#dont run this

$srcSite = Connect-Site -Url "*"
$dstSite = Connect-Site -Url "https://contoso-my.sharepoint.com/personal/*"
$result = Copy-List -All -SourceSite $srcSite -DestinationSite $dstSite
Export-Report $result -Path "C:\MyReports\CopyContentReports.xlsx"

Export-Report -SessionId * -Path "C:\MyReports\CopyContentReports.csv"

Clear-Variable dstSite
Clear-Variable dstList

$row.ONEDRIVEURL = "https://contoso-my.sharepoint.com/personal/account/"
$dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username "account@contoso.onmicrosoft.com" -Password $mypassword
$dstList = Get-List -Name Documents -Site $dstSite
Write-Output $dstlist
Import-Document -SourceFilePath $row.DIRECTORY -DestinationList $dstList -DestinationFolder "M365ImportedPersonalFolder"

#test
$dstSite = Connect-Site -Url $temp -Username "account@contoso.onmicrosoft.com" -Password $mypassword -verbose