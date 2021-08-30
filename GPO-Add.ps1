


$filter1 = Get-ADOrganizationalUnit -Filter 'Name -like "*Computers*"'

$filter1 = $filter1 | Where-Object -Property Name -NotLike -Value "*Production*"

$filter1 = $filter1 | Where-Object -Property Name -NotLike -Value "*Scale*"

foreach ($item in $filter1.DistinguishedName) {
    New-GPLink -Name "Name" -Target $item -LinkEnabled Yes
}





#For Prod Computers and Servers
$filter1 = Get-ADOrganizationalUnit -Filter 'Name -like "*Production Computers*"'

$filter2 = $filter1 | where { $_.Name -like "*US*" }

$filter3 = $filter1 | where { $_.Name -like "*CA*" }

$filtered1 = Get-ADOrganizationalUnit -Filter 'Name -like "*Production Servers*"'

$filtered2 = $filtered1 | where { $_.Name -like "*US*" }

$filtered3 = $filtered1 | where { $_.Name -like "*CA*" }


#Replace $filter2 with whichever list you want to use
foreach ($item in $filter2.DistinguishedName) {
    New-GPLink -Name "Name" -Target $item -LinkEnabled Yes
}

foreach ($item in $filter3.DistinguishedName) {
    New-GPLink -Name "Name" -Target $item -LinkEnabled Yes
}

foreach ($item in $filtered2.DistinguishedName) {
    New-GPLink -Name "Name" -Target $item -LinkEnabled Yes
}

foreach ($item in $filtered3.DistinguishedName) {
    New-GPLink -Name "Name" -Target $item -LinkEnabled Yes
}