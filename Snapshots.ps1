<# Directions:

Create Snapshots.csv and add the VM names of the machines with snapshots to create

Put Snapshots.csv onto PowerCLI server desktop

Copy/paste code below into Powershell admin window on the server(always start with a new Powershell window)

Use carmeuse\admaccount for username #>

#$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

$DesktopPath = "C:\Snapshots.csv"
$csvfile = "$DesktopPath" #CSV file of the VM's to have their snapshots removed

$vms = Get-Content $csvfile #Read the CSV File into a variable

$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter
 
$name = Read-Host -Prompt "What would you like to name the snapshot?"

#create snapshots
foreach($vm in $vms){
    $vm = get-VM $vm
    New-Snapshot -VM $vm -Name "$name" -Description "Created using Snapshot creator script by Quinn Favo on"
}

#remove snapshots
foreach($vm in $vms){
    $vm = get-VM $vm
    $vm | Get-Snapshot | Remove-Snapshot -confirm:$false
}