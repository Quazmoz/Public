#get password hashes for all users
Import-Module DSInternals
$cred = Get-Credential
$server = Read-Host -Prompt "Please enter the name of the domain controller"
Get-ADReplAccount -All -Server $server -NamingContext "dc=contoso,dc=net" `
-Credential $cred -Protocol TCP | Out-File C:\Users\qmfavo\Desktop\pwlist.txt