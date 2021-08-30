$OUpath = 'OU=US TC Users,OU=US TC,OU=US,OU=NAM,OU=contoso,DC=contoso,DC=net'
$userArray = Get-ADUser -Filter * -SearchBase $OUpath -properties * | Select-object *


#change description
foreach ($user in $userArray){
    
    $user.description = $user.description -replace "1", "2"
    
    Set-ADUser -Identity $user.samaccountname -Description $user.description
}

#change office
foreach ($user in $userArray){
    
    Set-ADUser -Identity $user.samaccountname -Office " Innovation Center"
}
Get-ADOrganizationalUnit -Filter 'Name -like "*us users*"'