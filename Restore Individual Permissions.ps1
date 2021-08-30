#run this on the server if it doesn't have the AD module installed yet
Import-Module ServerManager

Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature

Import-Module ActiveDirectory
#add a user to the acl for a folder, inheritance enabled
$folder = Read-Host -Prompt "Enter the name of the folder to modify"
$acl=get-acl d:\"$folder"
$user = Read-Host -Prompt "Enter 1st group to add"
$permtype = Read-Host -Prompt "Enter the type of permissions to grant (ReadandExecute, Modify, Full)"
$secadd = Get-ADGroup -Filter "Name -eq '$user'" -Properties SamAccountName
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$($secadd.SamAccountName)","$permtype",'ContainerInherit, ObjectInherit','none','Allow')
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl d:\"$folder"

#no inheritance
Import-Module ServerManager

Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
$acl=get-acl d:
$user = Read-Host -Prompt "Enter 1st group to add"
$permtype = Read-Host -Prompt "Enter the type of permissions to grant (ReadandExecute, Modify, Full)"
$secadd = Get-ADGroup -Filter "Name -eq '$user'" -Properties SamAccountName
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$($secadd.SamAccountName)","$permtype",'None','none','Allow')
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl d:\
Pause