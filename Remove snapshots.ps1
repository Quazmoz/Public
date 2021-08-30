#Create a basic .csv file with the names of the vms that should have their snapshots removed
#Place the file on the desktop with the name "Snapshots.csv"

$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

$csvfile = "$DesktopPath\Snapshots.csv" #CSV file of the VM's to have their snapshots removed
 
$logfile = "$DesktopPath\log.txt" #Script's log file location
 
  
 
$vms = Import-Csv $csvfile #Read the CSV File into a variable
 
$creds = Get-Credential #Get the user's credentials for vCenter (assumes the user has the same user/pass for all vCenters)
 
$timestamp = Get-Date #Get the current date/time and place entry into log that a new session has started
 
Add-Content $logfile "#####################################################"
 
Add-Content $logfile "$timestamp New Session Started"
 
  
 
$vcenters = $vms | Select-Object -ExpandProperty vCenter -Unique #Read the vCenters contained in the CSV and dedupe them
 
  
 
foreach ($vcenter in $vcenters) #Log into each vCenter included in the CSV file (assumes the user has the same user/pass for all vCenters)
 
{
 
$timestamp = Get-Date #Get the current date/time and place entry into log that the script is connecting to each vCenter
 
$message = "$timestamp Connecting to $vcenter"
 
Write-Host $message
 
Add-Content $logfile  $message
 
$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
#Connect-VIServer -Server $vCenter
#$Server = Read-host -Prompt "Please enter the name of the server you would like"
 
Connect-VIServer $vCenter -Credential $creds #Connect to the vCenter using the credentials provided at first run
 
  
 
Write-Host `n
 
}
 
  
 
foreach ($vm in $vms) #Remove snapshots for each VM in the CSV
 
{
 
$vm = get-VM $vm.VM #Load the virtual machine object
 
$snapshotcount = $vm | Get-Snapshot | Measure-Object #Get the number of snapshots for the VM
 
$snapshotcount = $snapshotcount.Count #This line makes it easier to insert the number of snapshots into the log file
 
  
 
$timestamp = Get-Date #Get the current date/time and place entry into log that the script is going to remove x number of shapshots for the VM
 
$message = "$timestamp Removing $snapshotcount Snapshot(s) for VM $vm"
 
Write-Host $message
 
Add-Content $logfile  $message
 
  
 
$vm | Get-Snapshot | Remove-Snapshot -confirm:$false | Out-File $logfile -Append #Removes the VM's snapshot(s) and writes any output to the log file
 
  
 
$timestamp = Get-Date #Get the current date/time and place entry into log that the script has finished removing the VM's snapshot(s)
 
Add-Content $logfile "$timestamp Snapshots removed for $vm"
 
}