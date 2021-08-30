#Run in admin powershell
#server1
Set-Location D:\PSTUploadFolders

#server2
Set-Location E:\PSTForMigration

$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

#create a csv file with the UPN of users (example on server1) and place on desktop
$folders = Get-Content "$desktopPath/pst.csv"

foreach ($folder in $folders){
    New-item -ItemType "directory" -Name $folder

    $acl=get-acl "$folder"
    $directory = Get-Item -Path ".\$folder"
    $acl.SetAccessRuleProtection($true,$false)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$folder","Modify",'ContainerInherit, ObjectInherit','none','Allow')
    $acl.SetAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\Domain Admins","Full",'ContainerInherit, ObjectInherit','none','Allow')
    $acl.SetAccessRule($AccessRule)
    #not working
    #$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("server1\SYSTEM","Full",'ContainerInherit, ObjectInherit','none','Allow')
    #$acl.SetAccessRule($AccessRule)
    
    $acl | Set-Acl "$directory"

    $shareName = "$folder`$"
    New-SmbShare -Name $shareName -Path $directory
    Grant-SmbShareAccess -Name $shareName -AccountName "Everyone" -AccessRight Change -Force
}