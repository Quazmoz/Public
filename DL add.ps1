#Text file must be manipulated first to contain only the name and email of each user.
#This can be accomplished by pasting all the names/emails into notepad, find and replace ; with , then save as csv.
#Open this csv with excel, copy/paste with transpose option then copy/paste into notepad and save as .txt
#Run the below on the .txt

$Users = Get-Content "C:\Users\favo\OneDrive - contoso.com\Desktop\users.csv"

$Users  -replace " <.*", "," | Out-File C:\Users\QMFAVO\Desktop\usersreadytoadd.csv

#Type "name," to the beginning of the file and save
#Copy/paste csv onto server
#Then run the below on the exchange server

$usersreadytoadd = Import-Csv 'C:\Users\favo\Desktop\usersreadytoadd.csv'

foreach ($User in $usersreadytoadd)
{
    Add-DistributionGroupMember -Identity "DL@contoso.com" -Member "$($User.name)"
}

#get rid of '
$Users = Get-Content 'C:\Users\QMFAVO\Desktop\usersreadytoadd.csv'

$Users  -replace "'", "" | Out-File C:\Users\QMFAVO\Desktop\usersreadytoadd.csv

#get rid of commas
$Users = Get-Content 'C:\Users\QMFAVO\Desktop\usersreadytoadd.csv'

$Users  -replace ",", "" | Out-File C:\Users\QMFAVO\Desktop\usersreadytoadd.csv

#Using var
foreach ($User in $members)
{
    Add-DistributionGroupMember -Identity "DL@contoso.com" -Member $User}