$Users = Get-Content 'C:\Users\FAVO\Desktop\users.txt'

foreach ($User in $Users)
{
    $sam = Get-ADUser -Filter {Surname -eq $User}
    Add-ADGroupMember -Identity 'Groupname' -Members $sam.SamAccountName
    Write-Host "$User" -ForegroundColor Green
    Write-Host "$User added to group"
}