$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

#test
$cim = New-CimSession -ComputerName usbrap100 -Credential $cred -Authentication Negotiate
Export-DhcpServer -CimSession $cim -File "\\server1\PST Checker\dhcpexport$($vm.name).xml" -verbose

#get all DHCP configs
$vms = Get-VM | Where-Object { $_.Name -like '*AP100*'}
$creds = Get-Credential
$session = New-PSSession -ComputerName Computer1 -Credential $creds
Invoke-Command -Session $session -ScriptBlock {
#$ErrorActionPreference = "SilentlyContinue"
foreach ($vm in $Using:vms) {
    #Export-DhcpServer -ComputerName "$($vm.name)" -File "\\server1\PST Checker\dhcpexport$($vm.name).xml" -verbose
    Enter-PSSession -ComputerName $vm.name
    Export-DhcpServer -ComputerName "server2" -File "\\server1\PST Checker\dhcpexport$($vm.name).xml" -verbose

}
}

foreach ($vm in $vms) {
    #Export-DhcpServer -ComputerName "$($vm.name)" -File "\\server1\PST Checker\dhcpexport$($vm.name).xml" -verbose
    Enter-PSSession -ComputerName $vm.name
    Export-DhcpServer -ComputerName "$($vm.name)" -File "\\server1\PST Checker\dhcpexport$($vm.name).xml" -verbose
Exit-PSSession
}

#single
Export-DhcpServer -ComputerName "server2" -File "\\server1\PST Checker\dhcpexport.xml"