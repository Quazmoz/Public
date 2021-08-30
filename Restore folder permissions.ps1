#cd to drive/folder you would like to add permissions for

$foldernames = Get-ChildItem -Name

Foreach ($name in $foldernames) {
    $acl = Get-Acl "..\$name"
    $first,$last = $name -split " "
    $name = "$last $first"
    $user = Get-ADUser -Filter "Name -eq '$name'" -Properties SamAccountName

    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$($user.SamAccountName)","Modify","Allow")
    
    $acl.SetAccessRule($AccessRule)

    $acl.SetAccessRuleProtection($False,$True)

    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\IT Help Desk","FullControl","Allow")
    
    $acl.SetAccessRule($AccessRule)

    $acl.SetAccessRuleProtection($False,$True)

    $first,$last = $name -split " "
    $name = "$last $first"
    $acl | Set-Acl "..\$name"
}

#without helpdesk
Foreach ($name in $foldernames) {
    $acl = Get-Acl "..\$name"
    $first,$last = $name -split " "
    $name = "$last $first"
    $user = Get-ADUser -Filter "Name -eq '$name'" -Properties SamAccountName

    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$($user.SamAccountName)",'ContainerInherit, ObjectInherit','1',"Allow")
    
    $acl.SetAccessRule($AccessRule)

    $first,$last = $name -split " "
    $name = "$last $first"
    $acl | Set-Acl "..\$name"
}

#remove one user
Foreach ($name in $foldernames) {
    $acl=get-acl e:\"$name"
    $first,$last = $name -split " "
    $name = "$last $first"
    $user = Get-ADUser -Filter "Name -eq '$name'" -Properties SamAccountName

    $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule("contoso\AWLONGWORTH","Read",,,"Allow")
    $acl.RemoveAccessRuleAll($accessrule)

    $first,$last = $name -split " "
    $name = "$last $first"
    Set-Acl -Path "e:\$name" -AclObject $acl
}
