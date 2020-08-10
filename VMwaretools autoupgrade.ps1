#Install PowerCLI
Find-Module -Name VMware.PowerCLI
Install-Module -Name VMware.PowerCLI -Scope CurrentUser

#Allow connection without verified cert and opt out of Customer feedback program
Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCeip $false -InvalidCertificateAction Ignore

#Connect to VCenter
$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

# VMware Tools Automatic Upgrade on PowerCycle
#Create powershell objects
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

$vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo

$vmConfigSpec.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"

#Loop through VMs and set parameter for upgrade tools on powercycling - this only changes the VMs that are currently not set to automatically upgrade tools
Get-VM | Where {$_.ExtensionData.Config.Tools.ToolsUpgradePolicy -like "manual"} | ForEach { $_.ExtensionData.ReconfigVM_task($vmConfigSpec) }

#Testing per VM
#Prompt for vCenter server name and connect via PowerCLI
$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

$vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo

$vmConfigSpec.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"

#Test by applying to one server
$testserver = Read-Host -Prompt "Please enter a server that is configured as manual for testing purposes"
$test = Get-VM -Name $testserver
$test.ExtensionData.ReconfigVM_task($vmConfigSpec)