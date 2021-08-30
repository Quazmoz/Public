#Connect to VCenter
$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

$vms = Get-VM

Foreach($vm in $vms){
    If ($vm.name -like "*VDP*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.folder -like "*LAN*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.folder -like "*Test VMs*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.folder -like "*SAP*"){
        Write-Output "Skipped $($vm.name)"
    }
    <# elseif($vm.name -like "*vm*"){
        Write-Output "Skipped $($vm.name)"
    } #>
    elseif($vm.folder -like "*Cluster-PG*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.folder -like "*Cluster-LLN*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.folder -like "*Cluster-MA*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.folder -like "*Cluster-SP*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.name -like "*CS*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.name -like "*BEMA*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.name -like "*CZPG*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.name -like "*BELN*"){
        Write-Output "Skipped $($vm.name)"
    }
    elseif($vm.name -like "*DMZ*"){
        Write-Output "Skipped $($vm.name)"
    }
    else{
        $vm.name | Add-Content -Path "C:/vms.txt"
    }
}

#test

Foreach($vm in $vms){
    If ($vm.name -like "*VDP*"){
        Write-Output $vm.name
    }
}