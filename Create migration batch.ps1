#only run this the first time you run it, run as admin, answer yes to all the prompts
Set-ExecutionPolicy RemoteSigned

Install-Module -Name ExchangeOnlineManagement

Import-module Exchangeonlinemanagement


#run this to log into exchange online
Connect-ExchangeOnline

$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

#run this next and enter the requested value
$batchName = Read-Host -Prompt "What would you like to name this batch? (Usually this is a date and number provided by the excel doc)"

#then run this with the emails input inside
$fileName = "migrationbatch"

#run this last to create batches (csv should use email address)
New-MigrationBatch -Name $batchName -SourceEndpoint hybrid.contoso.com -TargetDeliveryDomain contoso.mail.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("$desktopPath\$fileName.csv")) -AutoStart