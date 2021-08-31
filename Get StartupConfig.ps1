$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

Get-VM | Get-VMStartPolicy | select VM,StartAction

#get start policy
$vms = Get-VM | Get-VMStartPolicy

$filtered = $vms | Where-Object -property "StartAction" -eq "none"
$filtered = $filtered | Where-Object -property "VM" -NotLike "*Server*"
$filtered2 = $filtered | Where-Object VM -Like "*FS*"
$filtered3 = $filtered | Where VM -Like "*AP100*" 
$filtered4 = $filtered | Where VM -Like "*AP102*"
$filtered5 = $filtered | Where VM -Like "*DC100*"
#set startpolicy
foreach ($vm in $filtered2) {
    $vmhost = Get-VMHost -VM $vm.vm
    Get-VMHostStartPolicy -VMHost (Get-VMHost -Name $vmhost.name) | Set-VMHostStartPolicy -Enabled $true
    Get-VMStartPolicy -vm $vm.vm | Set-VMStartPolicy -StartAction PowerOn

}

foreach ($vm in $filtered3) {
    $vmhost = Get-VMHost -VM $vm.vm
    Get-VMHostStartPolicy -VMHost (Get-VMHost -Name $vmhost.name) | Set-VMHostStartPolicy -Enabled $true
    Get-VMStartPolicy -vm $vm.vm | Set-VMStartPolicy -StartAction PowerOn

}

foreach ($vm in $filtered4) {
    $vmhost = Get-VMHost -VM $vm.vm
    Get-VMHostStartPolicy -VMHost (Get-VMHost -Name $vmhost.name) | Set-VMHostStartPolicy -Enabled $true
    Get-VMStartPolicy -vm $vm.vm | Set-VMStartPolicy -StartAction PowerOn

}

foreach ($vm in $filtered5) {
    $vmhost = Get-VMHost -VM $vm.vm
    Get-VMHostStartPolicy -VMHost (Get-VMHost -Name $vmhost.name) | Set-VMHostStartPolicy -Enabled $true
    Get-VMStartPolicy -vm $vm.vm | Set-VMStartPolicy -StartAction PowerOn

}


#test
$hosts = Get-VMHost |Get-VMHostStartPolicy
Get-VMStartPolicy -vm USPGFS001 | Set-VMStartPolicy -StartAction PowerOn
