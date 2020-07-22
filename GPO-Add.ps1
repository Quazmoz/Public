$filter1 = Get-ADOrganizationalUnit -Filter 'Name -like "*Production Computers*"'

$filter2 = $filter1 | where { $_.Name -like "*US*" }

$filter3 = $filter1 | where { $_.Name -like "*CA*" }

$filtered1 = Get-ADOrganizationalUnit -Filter 'Name -like "*Production Servers*"'

$filtered2 = $filtered1 | where { $_.Name -like "*US*" }

$filtered3 = $filtered1 | where { $_.Name -like "*CA*" }


#Replace $filter2 with whichever list you want to use
foreach ($item in $filter2.DistinguishedName) {
    New-GPLink -Name "WEUR - Computers - IE Security Management" -Target $item -LinkEnabled Yes
}

foreach ($item in $filter3.DistinguishedName) {
    New-GPLink -Name "WEUR - Computers - IE Security Management" -Target $item -LinkEnabled Yes
}

foreach ($item in $filtered2.DistinguishedName) {
    New-GPLink -Name "WEUR - Computers - IE Security Management" -Target $item -LinkEnabled Yes
}

foreach ($item in $filtered3.DistinguishedName) {
    New-GPLink -Name "WEUR - Computers - IE Security Management" -Target $item -LinkEnabled Yes
}