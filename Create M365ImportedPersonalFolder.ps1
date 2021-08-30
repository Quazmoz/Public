#put the users' UPNs in the csv file and place it on the desktop of a domain controller then run the below in admin powershell

#run this first
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$fileName = "migrationbatchUPN"

#then run this
$file = "$desktopPath\$fileName.csv"
$inputCsv = Import-Csv $file | Sort-Object * -Unique

#Use global admin account to log in
#Create subfolder
foreach ($user in $inputCsv.UPN) {

       Connect-PnPOnline -Tenant contoso.onmicrosoft.com -ClientId ca9f4d9d-4f1b-468b-b8a2-a832c88b0a0f -Thumbprint E64CBBE1EEE92B28F658D9A838AE10546F66F92F -Url "https://contoso-my.sharepoint.com/personal/$($user)_contoso_net"

       Add-PnPFolder -Name "M365ImportedPersonalFolder" -Folder "Documents" -Verbose #-Connection $connection
       Write-Host "$user M365ImportedPersonalFolder Created"
}

#single user
$username = Read-Host -Prompt "Enter the user you would like to create the M365 import folder for"
Connect-PnPOnline -Tenant contoso.onmicrosoft.com -ClientId ca9f4d9d-4f1b-468b-b8a2-a832c88b0a0f -Thumbprint E64CBBE1EEE92B28F658D9A838AE10546F66F92F -Url "https://contoso-my.sharepoint.com/personal/$($username)_contoso_net"
Add-PnPFolder -Name "M365ImportedPersonalFolder" -Folder "Documents" -Verbose

$SiteURL= "https://contoso.sharepoint.com/sites/AdminArea"
$cred = Get-Credential

#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Credentials $cred -Verbose
Set-PnPSite -Identity $SiteURL -DenyAndAddCustomizePages $false
#Exclude Root Web of the Site Collection from Search Index
$Web = Get-PnPWeb
$Web.NoCrawl = $true
$Web.Update()
Invoke-PnPQuery 

#other Francois script
Connect-PnPOnline –Url https://contoso-admin.sharepoint.com -Credentials $cred
New-PnPSite -Type TeamSite -Title 'Team pnpfco1' -Alias pnpfco1
New-PnPSite -Type CommunicationSite -Title 'Com pnpfco2' -Url https://contoso.sharepoint.com/sites/PnPFco2 
