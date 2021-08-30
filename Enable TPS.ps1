$vCenter = Read-host -Prompt "Please enter the name of the vCenter server"
Connect-VIServer -Server $vCenter

#view current settings
Get-VMhost | select Name, @{Name="Value";  Expression={Get-AdvancedSetting -Name Mem.ShareForceSalting -Entity $_}} | sort Value | ft -AutoSize

#change settings for all hosts
Get-VMhost | Get-AdvancedSetting -Name Mem.ShareForceSalting |  Set-AdvancedSetting –Value 0

#view setting for all VMs
Get-VM | select Name, @{Name="Value";  Expression={Get-AdvancedSetting -Name Mem.ShareForceSalting -Entity $_}} | sort Value | ft -AutoSize

#change setting for all VMs
Get-VM | Get-AdvancedSetting -Name sched.mem.pshare.salt |  Set-AdvancedSetting –Value 0