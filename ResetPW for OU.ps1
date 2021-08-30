#reset all users' passwords in an AD group

$users = Get-ADUser -Filter * -SearchBase "OU=US YA Users,OU=US YA,OU=US,OU=NAM,OU=Contoso,DC=Contoso,DC=net"

Foreach($user in $users){
    Set-ADAccountPassword -Identity $user.SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Password1" -Force)
    Write-Output $user.name
}