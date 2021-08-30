# To enable copy/paste via VMware console: https://pubs.vmware.com/vsphere-4-esx-vcenter/index.jsp?topic=/com.vmware.vsphere.server_configclassic.doc_41/esx_server_config/security_deployments_and_recommendations/t_enable_copy_and_paste_operations_between_the_guest_operating_system_and_remote_console.html

#*****ALWAYS RUN POWERSHELL AS ADMIN*****

#Domain join
#Prompts to guide through credential requests
$wshell = New-Object -ComObject Wscript.Shell

$wshell.Popup("Please enter your domain admin username/password",0," ",0)

$DomainAdminCreds = Get-Credential
#$wshell.Popup("Please enter your local admin username/password",0," ",0)
#$LocalCreds = Get-Credential
$CompName = Read-Host -Prompt "Please enter the new computer name"

$DomainName = Read-Host -Prompt "Please enter the domain to join e.g. contoso.net"

$oldcompname = $env:computername | Select-Object
Add-Computer -DomainName $DomainName -ComputerName "$oldcompname" -Credential $DomainAdminCreds
Write-output "The computer was added to the domain"
Rename-Computer -NewName "$CompName" -DomainCredential $DomainAdminCreds
Write-output "The computer will restart in 15 seconds"
Write-output "Sometimes the computer renaming will fail if it hits a DC running Server 2012 R2, if this happens you will need to rename the computer manually"
Start-Sleep -Seconds 15
Restart-Computer -Force