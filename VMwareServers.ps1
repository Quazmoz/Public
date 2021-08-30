$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

$vm = Get-VM
$i = 0
$vdpservers = @()
Foreach($item in $vm.name){
    If ($item -like "*vdp*"){
        $vdpservers += $item
        $i++
    }
}

$vdpservers | Out-file "C:\Temp\VMs.csv"

$i = 0
Foreach($server in $vdpservers)
{
    ping -a $vdpservers[$i]
    $i++
}

$vm | Select-Object -Property Guest, PowerState | Export-CSV -Path "C:\Temp\VMs.csv" 