#get all the OUs you want to place the new group in, filter it by name or by whichever specifics you choose
$OUs = Get-ADOrganizationalUnit -Filter 'Name -like "*Production Groups*"'

#Output all group distinguishednames to txt file
foreach ($OU in $OUs) {

    if ($OU.name -NotLike "*US*" -and $OU.name -NotLike "*CA*") {
    
        Write-Output $OU.name
        $OU.distinguishedname | Out-File -Append -FilePath C:\Users\QMFAVO\Desktop\prodgroups.txt
    }

}

#get desktop path for txt file to pull distinguishednames
$DesktopPath = [Environment]::GetFolderPath("Desktop")
#put this file on the desktop of exchange server
$distnames = Get-Content $DesktopPath\prodgroups.txt

#get group to use as manager for new groups
$manager = Get-ADGroup 'Group'
#add groups
foreach ($distname in $distnames) {
        
    $groupName = $distname.substring(3, 5) + " PRODUCTION Computers OLD"
    $groupName2 = $distname.substring(3, 5) + " PRODUCTION Computers NEW"
    New-ADGroup -Name $groupName -DisplayName $groupName -ManagedBy $manager -Path $distName -GroupScope Universal
    New-ADGroup -Name $groupName2 -DisplayName $groupName2 -ManagedBy $manager -Path $distName -GroupScope Universal
    Write-Output "Group created:"
    Write-Output $groupName
    Write-Output "In OU:"
    Write-Output $distName

    Write-Output "Group created:"
    Write-Output $groupName2
    Write-Output "In OU:"
    Write-Output $distName
}

#Below is the snippet to add manager permissions to edit list of members in group but it requires the highest permission in exchange to perform
Add-ADPermission -Identity "testgroup1" -User $manager.name -AccessRights WriteProperty -Properties "Member"

#get desktop path for txt file to pull distinguishednames
$DesktopPath = [Environment]::GetFolderPath("Desktop")
#put this file on the desktop of exchange server
$distnames = Get-Content $DesktopPath\prodgroups.txt
foreach ($distname in $distnames) {
        
    $groupName = $distname.substring(3, 5) + " PRODUCTION Computers OLD"
    $groupName2 = $distname.substring(3, 5) + " PRODUCTION Computers NEW"
    Add-ADPermission -Identity $groupName -User $manager.name -AccessRights WriteProperty -Properties "Member"
    Add-ADPermission -Identity $groupName2 -User $manager.name -AccessRights WriteProperty -Properties "Member"
    Write-Output "Groups modified"
    Write-Output $groupName
    Write-Output $groupName2
    
}