#Connect to VCenter
$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter
$Server = Read-host -Prompt "Please enter the name of the server you would like to enable copy/paste on. The server will reboot."
$Reboot = Read-Host -Prompt "Would you like to reboot the server now? [Y] or [N]"
$vm = Get-VM -Name $Server
foreach ($item in $vm){
                New-AdvancedSetting `
                    -Entity $item `
                    -Name isolation.tools.copy.disable `
                    -Value $false `
                    -confirm:$false `
                    -force:$true `
                    -errorAction 'Continue'
                Write-Verbose -Message "$item - Setting the isolation.tools.paste.disable AdvancedSetting to $false..."
                New-AdvancedSetting `
                    -Entity $item `
                    -Name isolation.tools.paste.disable `
                    -Value $false `
                    -confirm:$false `
                    -force:$true `
                    -errorAction 'Continue'
                If ($Reboot -eq "Y"){
                Start-Sleep -Seconds 15
                Shutdown-VMGuest -VM $item -Confirm:$false
                Write-output "VM is shutting down"
                Start-Sleep -Seconds 120
                Start-VM -VM $item
                Write-output "VM is starting"
                }
                else {
                    Write-Output "Copy/Paste is enabled but will not take effect until the virtual machine is fully powered down and back on"
                }
                }