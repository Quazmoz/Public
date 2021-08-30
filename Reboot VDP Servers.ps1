#Connect to VCenter
$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

$vms = Get-VM

Foreach($vm in $vms){
    If ($vm.name -like "*VDP*"){
        Restart-VMGuest $vm.name
    }
}

#test

Foreach($vm in $vms){
    If ($vm.name -like "*VDP*"){
        Write-Output $vm.name
    }
}