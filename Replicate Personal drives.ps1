Import-Module ServerManager

Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature

#verify after completing
$folders = Get-ChildItem -Path E:\ -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
foreach($name in $folders.fullname){
    $userspec = $name.Substring(3)
    $first,$last = $userspec -split " "
    $userspec = "$last $first"
    $user = Get-ADUser -Identity "$userspec"
    Write-Output $user.homedrive
}
#actual
$folders = Get-ChildItem -Path D:\PrivateData -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

#testing
foreach($name in $folders.fullname){
    $userspec = $name.Substring(15)
    $user = Get-ADUser -Identity "$userspec"
    Write-Output $user.homedrive
}

Foreach ($name in $folders.fullname) {
    $userspec = $name.Substring(15)
    $first,$last = $userspec -split " "
    $userspec = "$last $first"

    $user = Get-ADUser -Filter "Name -eq '$userspec'" -Properties Name,CanonicalName,CN,DisplayName,DistinguishedName,HomeDirectory,`
    HomeDrive,SamAccountName,UserPrincipalName

if($user -eq $null){

Write-Output("$userspec not found")
}

    Write-Output ($user)
}

#Moves smb shares and folders from one drive to another

Start-Transcript -path C:\output.txt -append

$folders = Get-ChildItem -Path D:\PrivateData -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

$shares = Get-SmbShare | Where-Object {$_.Path -like "D:\PrivateData*"}
$shares2 = Get-SmbShare | Where-Object {$_.Path -like "D:\PrivateData*"}
$i = 0

Foreach($folder in $folders.Fullname)
{
    $newpath = "E:" + $folder.Substring(14)
    Write-Output "Copying $folder into ", $newpath
    cp $folder $newpath -Recurse
}
$i = 0
#broken, only removes
Foreach($share in $shares)
    {
        #$shares.Path[$i] = 0
        $userspec = $share.Path.Substring(14)
        Write-output($userspec)
        Write-Output($shares.Path[$i])
        $share.name = $share.name + "$"
        Write-Output($share.name)
        Remove-SmbShare -Name $share.name -Force
        #$folder = $folders[$i]
        #$sharepath = $folder.Substring(14)
        #New-SmbShare -Name $share.name -Path $sharepath
        $i++
    }

Stop-Transcript

#temp fix to add SMB shares
Foreach($share in $shares)
{
    $fixpath = "E:" + $share.Path.substring(14)
    New-SmbShare -Name $share.name -Path $fixpath
}

#USBR and a few others CAREFUL WITH THIS, DONT LET IT REMOVE VALID ENTRIES
Foreach($share in $shares)
{
    Remove-SmbShare -Name $share.name -Force
    $fixpath = "E:" + $share.Path.substring(14)
    New-SmbShare -Name $share.name -Path $fixpath
}

#other fix to give change permissions for shares
$shares = Get-SmbShare | Where-Object {$_.Path -like "E:\*"}
Foreach($share in $shares)
{
    Grant-SmbShareAccess -Name $share.name -AccountName "Everyone" -AccessRight Change -Force
}

#add back the user's modify permission and add smbshare
$newFolders = Get-ChildItem -Path E:\ -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

Foreach ($item in $NewFolders.fullname) {
    
    $itemSpec = $item.Substring(3)
    $first,$last = $itemSpec -split " "
    $itemSpec = "$last $first"

    $acl=get-acl "$item"
    
    $secadd = Get-ADUser -Filter "Name -eq '$itemSpec'" -Properties SamAccountName
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$($secadd.SamAccountName)","Modify",'ContainerInherit, ObjectInherit','none','Allow')
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl "$item"
    $shareName = "$($secadd.samaccountname)`$"
    New-SmbShare -Name $shareName -Path $item
    }

    #check account home path

    #big batch fix before mover.io migration

    #Get users in AD and show filepaths
    #bad filepaths -> change
    #check ad vs smbshares
    #different ones, fix to correct

    #essentially: fix ad path, fix smbpath