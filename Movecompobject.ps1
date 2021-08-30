#General use
$input = Read-host -Prompt "Enter the name of the OU to move into"
$compname = Read-host -Prompt "Enter the name of the computer to move"

$target = Get-ADOrganizationalUnit -LDAPFilter “(name=$input)”

Get-adcomputer $compname | Move-ADObject -TargetPath $target.DistinguishedName

#move multiple computers based on a list
$input = Read-host -Prompt "Enter the name of the OU to move into"

$target = Get-ADOrganizationalUnit -LDAPFilter “(name=$input)”
$comps = Get-Content 'C:\comps.txt'
foreach($compname in $comps){
Get-adcomputer $compname | Move-ADObject -TargetPath $target.DistinguishedName
}
