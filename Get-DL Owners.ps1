#given a list of DLs by HR, put them in the file below and then run the script on it to find and output the owners
#make sure you run this with an account that has admin permissions for AD
$dls = Get-Content 'C:\Users\ADMQMFAVO\Desktop\dls.txt'

foreach ($dl in $dls){

$owner = Get-DistributionGroup -Identity "$dl"

Write-Output $owner

$owner.Name | Out-file -Append 'C:\Users\ADMQMFAVO\Desktop\dlcomplete.csv'
$owner.ManagedBy.Name | Out-file -Append 'C:\Users\ADMQMFAVO\Desktop\dlcomplete.csv'
}