#*****ALWAYS RUN POWERSHELL AS ADMIN*****
#Run Copy/paste script in PowerCLI first, then Domainjoin, then the below

#Set environment variables
$ErrorActionPreference= 'silentlycontinue'

#GUI to gather info
$Disk0 = Get-Disk -Number 0
$Disk0Size = [math]::round($Disk0.size /1Gb, 0)
$Disk1 = Get-Disk -Number 1
$Disk1Size = [math]::round($Disk1.size /1Gb, 0)
$Disk2 = Get-Disk -Number 2
$Disk2Size = [math]::round($Disk2.size /1Gb, 0)

#Begin form init and standard form elements
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Automatic Server Config Tool'
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(300,500)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(400,500)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

#Column 1
#Change the timezone
$checkboxTimezone = New-Object System.Windows.Forms.Checkbox 
$checkboxTimezone.Location = New-Object System.Drawing.Size(10,10) 
$checkboxTimezone.Size = New-Object System.Drawing.Size(150,20)
$checkboxTimezone.Text = "Change Timezone"
$checkboxTimezone.Checked = $true
$form.Controls.Add($checkboxTimezone)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,30)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select a timezone:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,50)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 80
$form.Controls.Add($listBox)
[void] $listBox.Items.Add('Eastern Standard Time')
[void] $listBox.Items.Add('Central Standard Time')
[void] $listBox.Items.Add('Pacific Standard Time')
[void] $listBox.Items.Add('Romance Standard Time')
[void] $listBox.Items.Add('Central Europe Standard Time')

#Move Server into correct OU
$checkboxServer = New-Object System.Windows.Forms.Checkbox 
$checkboxServer.Location = New-Object System.Drawing.Size(10,120) 
$checkboxServer.Size = New-Object System.Drawing.Size(200,20)
$checkboxServer.Text = "Move Server Into Correct OU"
$checkboxServer.Checked = $true
$form.Controls.Add($checkboxServer)

$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Location = New-Object System.Drawing.Point(10,140)
$labelServer.Size = New-Object System.Drawing.Size(280,30)
$labelServer.Text = 'Please enter the name of a server at the same site'
$form.Controls.Add($labelServer)

$textBoxServer = New-Object System.Windows.Forms.TextBox
$textBoxServer.Location = New-Object System.Drawing.Point(10,170)
$textBoxServer.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxServer)

#Add user to local admin
$checkboxUser = New-Object System.Windows.Forms.Checkbox 
$checkboxUser.Location = New-Object System.Drawing.Size(10,200) 
$checkboxUser.Size = New-Object System.Drawing.Size(200,20)
$checkboxUser.Text = "Add user account to local admin"
$checkboxUser.Checked = $false
$form.Controls.Add($checkboxUser)

$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Location = New-Object System.Drawing.Point(10,220)
$labelUser.Size = New-Object System.Drawing.Size(280,30)
$labelUser.Text = 'Please enter the username you would like to add as an admin for this server)'
$form.Controls.Add($labelUser)

$textBoxUser = New-Object System.Windows.Forms.TextBox
$textBoxUser.Location = New-Object System.Drawing.Point(10,250)
$textBoxUser.Size = New-Object System.Drawing.Size(260,20)
$textBoxUser.text = "domain\"
$form.Controls.Add($textBoxUser)

#Change IP Address
$checkboxIP = New-Object System.Windows.Forms.Checkbox 
$checkboxIP.Location = New-Object System.Drawing.Size(10,270) 
$checkboxIP.Size = New-Object System.Drawing.Size(150,20)
$checkboxIP.Text = "Change IP Address"
$checkboxIP.Checked = $true
$form.Controls.Add($checkboxIP)

$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Location = New-Object System.Drawing.Point(10,290)
$labelIP.Size = New-Object System.Drawing.Size(280,30)
$labelIP.Text = 'Please enter the IP Address for the server in the format x.x.x.x'
$form.Controls.Add($labelIP)

$textBoxIP = New-Object System.Windows.Forms.TextBox
$textBoxIP.Location = New-Object System.Drawing.Point(10,320)
$textBoxIP.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxIP)

$labelGateway = New-Object System.Windows.Forms.Label
$labelGateway.Location = New-Object System.Drawing.Point(10,340)
$labelGateway.Size = New-Object System.Drawing.Size(280,30)
$labelGateway.Text = 'Please enter the default gateway and DNS servers in the format x.x.x.x'
$form.Controls.Add($labelGateway)

$textBoxGateway = New-Object System.Windows.Forms.TextBox
$textBoxGateway.Location = New-Object System.Drawing.Point(10,370)
$textBoxGateway.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxGateway)

$textBoxDNS1 = New-Object System.Windows.Forms.TextBox
$textBoxDNS1.Location = New-Object System.Drawing.Point(10,390)
$textBoxDNS1.Size = New-Object System.Drawing.Size(260,20)
$textBoxDNS1.Text = "Please enter the DNS server IP"
$form.Controls.Add($textBoxDNS1)

$textBoxDNS2 = New-Object System.Windows.Forms.TextBox
$textBoxDNS2.Location = New-Object System.Drawing.Point(10,410)
$textBoxDNS2.Size = New-Object System.Drawing.Size(260,20)
$textBoxDNS2.Text = "Please enter the DNS server IP"
$form.Controls.Add($textBoxDNS2)

#Column 2
#Format disk
$checkboxDrive = New-Object System.Windows.Forms.Checkbox 
$checkboxDrive.Location = New-Object System.Drawing.Size(300,10) 
$checkboxDrive.Size = New-Object System.Drawing.Size(150,20)
$checkboxDrive.Text = "Format Disk"
$checkboxDrive.Checked = $true
$form.Controls.Add($checkboxDrive)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(300,30)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = 'Please select a disk to format based on size:'
$form.Controls.Add($label2)

$listBox2 = New-Object System.Windows.Forms.ListBox
$listBox2.Location = New-Object System.Drawing.Point(300,50)
$listBox2.Size = New-Object System.Drawing.Size(260,20)
$listBox2.Height = 80
$form.Controls.Add($listBox2)
[void] $listBox2.Items.Add("$($Disk0Size) GB")
[void] $listBox2.Items.Add("$($Disk1Size) GB")
[void] $listBox2.Items.Add("$($Disk2Size) GB")

$labelDrive = New-Object System.Windows.Forms.Label
$labelDrive.Location = New-Object System.Drawing.Point(580,20)
$labelDrive.Size = New-Object System.Drawing.Size(140,20)
$labelDrive.Text = 'Please input a drive letter'
$form.Controls.Add($labelDrive)

$textBoxDrive = New-Object System.Windows.Forms.TextBox
$textBoxDrive.Location = New-Object System.Drawing.Point(580,50)
$textBoxDrive.Size = New-Object System.Drawing.Size(30,20)
$form.Controls.Add($textBoxDrive)

$labelDriveLabel = New-Object System.Windows.Forms.Label
$labelDriveLabel.Location = New-Object System.Drawing.Point(730,20)
$labelDriveLabel.Size = New-Object System.Drawing.Size(140,20)
$labelDriveLabel.Text = 'Please input the drive label'
$form.Controls.Add($labelDriveLabel)

$textBoxDriveLabel = New-Object System.Windows.Forms.TextBox
$textBoxDriveLabel.Location = New-Object System.Drawing.Point(730,50)
$textBoxDriveLabel.Size = New-Object System.Drawing.Size(140,20)
$form.Controls.Add($textBoxDriveLabel)

$checkboxActivate = New-Object System.Windows.Forms.Checkbox 
$checkboxActivate.Location = New-Object System.Drawing.Size(300,120) 
$checkboxActivate.Size = New-Object System.Drawing.Size(150,20)
$checkboxActivate.Text = "Activate Windows"
$form.Controls.Add($checkboxActivate)

$textKey = New-Object System.Windows.Forms.TextBox
$textKey.Location = New-Object System.Drawing.Point(450,120)
$textKey.Size = New-Object System.Drawing.Size(260,20)
$textKey.text = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
$form.Controls.Add($textKey)

$checkboxRDP = New-Object System.Windows.Forms.Checkbox 
$checkboxRDP.Location = New-Object System.Drawing.Size(300,140) 
$checkboxRDP.Size = New-Object System.Drawing.Size(150,20)
$checkboxRDP.Text = "Enable RDP"
$checkboxRDP.Checked = $true
$form.Controls.Add($checkboxRDP)

$checkboxDisableiPv6 = New-Object System.Windows.Forms.Checkbox 
$checkboxDisableiPv6.Location = New-Object System.Drawing.Size(300,160) 
$checkboxDisableiPv6.Size = New-Object System.Drawing.Size(150,20)
$checkboxDisableiPv6.Text = "Disable iPv6"
$checkboxDisableiPv6.Checked = $true
$form.Controls.Add($checkboxDisableiPv6)

#$checkboxTrend = New-Object System.Windows.Forms.Checkbox 
#$checkboxTrend.Location = New-Object System.Drawing.Size(300,180) 
#$checkboxTrend.Size = New-Object System.Drawing.Size(300,20)
#$checkboxTrend.Text = "Install Trend Micro Officescan Agent"
#$checkboxTrend.Checked = $true
#$form.Controls.Add($checkboxTrend)

$checkboxUpdate = New-Object System.Windows.Forms.Checkbox 
$checkboxUpdate.Location = New-Object System.Drawing.Size(300,200) 
$checkboxUpdate.Size = New-Object System.Drawing.Size(300,20)
$checkboxUpdate.Text = "Install Windows Updates (automatic reboot)"
$checkboxUpdate.Checked = $true
$form.Controls.Add($checkboxUpdate)

$checkboxNICPower = New-Object System.Windows.Forms.Checkbox 
$checkboxNICPower.Location = New-Object System.Drawing.Size(300,220) 
$checkboxNICPower.Size = New-Object System.Drawing.Size(300,20)
$checkboxNICPower.Text = "Disable NIC Power Management"
$checkboxNICPower.Checked = $true
$form.Controls.Add($checkboxNICPower)

$checkboxCD = New-Object System.Windows.Forms.Checkbox 
$checkboxCD.Location = New-Object System.Drawing.Size(300,240) 
$checkboxCD.Size = New-Object System.Drawing.Size(300,20)
$checkboxCD.Text = "Change CD Drive letter to J"
$checkboxCD.Checked = $true
$form.Controls.Add($checkboxCD)

$form.Topmost = $true

$result = $form.ShowDialog()

#Move Server into correct OU
If ($checkboxServer.Checked -eq $true){
#First turn on AD powershell cmdlets
Import-Module ServerManager

Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature

#Move ADObject
$NewServerName = $env:computername | Select-Object
$OtherServer = Get-ADComputer $textBoxServer.text
$Grab = "$OtherServer"
$OrgUnit = $Grab.substring(13)
$FullServerName = Get-ADComputer "$NewServerName"
$FullServerName | Move-ADObject -TargetPath "$OrgUnit"
Write-output "Computer object was moved to: $OrgUnit"
}

#Disable ipv6
If ($checkboxDisableiPv6.Checked -eq $true){
Disable-NetAdapterBinding –InterfaceAlias “Ethernet0” –ComponentID ms_tcpip6
Write-output "iPv6 was disabled"
}

#Change CD drive letter (tweak depending on type of server and deployment location, sometimes can initially be set to E drive)
If ($checkboxCD.Checked -eq $true){
$drv = Get-WmiObject win32_volume -filter 'DriveType = "5"'
$drv.DriveLetter = "J:"
$drv.Put() | out-null
Write-output "Drive letter changed to J"
}

#Initialize disk(s) and create partitions
If ($checkboxDrive.Checked -eq $true){
Initialize-disk -Number $listBox2.SelectedIndex
Get-Disk -Number $listBox2.SelectedIndex | New-Partition -UseMaximumSize -DriveLetter $textBoxDrive.text | Format-Volume -FileSystem NTFS -NewFileSystemLabel $textBoxDriveLabel.Text -Confirm:$False
Write-output "Disk was successfully created $($textBoxDrive.text) $($textBoxDriveLabel.text)"
}

#Add users to admin group - change this depending on needs
If ($checkboxUser.Checked -eq $true){
Add-LocalGroupMember -Group "Administrators" -Member $textBoxUser.text
Write-output "Added user: $($textBoxUser.text)"
}

#Set timezone
If ($checkboxTimezone.Checked -eq $true){
Set-TimeZone -Name $listBox.SelectedItem

Write-output "Timezone changed successfully to: $($listBox.SelectedItem)"
}

#Enable RDP
If ($checkboxRDP.Checked -eq $true){
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name “fDenyTSConnections” -Value 0

Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name “UserAuthentication” -Value 1

Enable-NetFirewallRule -DisplayGroup “Remote Desktop”

Write-output "RDP was enabled"
}

#Set IP
If ($checkboxIP.Checked -eq $true){
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Dns = $textBoxDNS1.Text
$DNS2 = $textBoxDNS2.Text
$Gateway = $textBoxGateway.Text
$IP = $textBoxIP.Text
$IPType = "IPv4"

#Check for gateway error
If ($Gateway.substring(0,9) -ne $IP.substring(0,9)){
    Write-Output "Please double check the gateway"
    Write-Output "IP address is set to $IP"
    Write-Output "Gateway is set to $Gateway"
    $Gateway = Read-Host -Prompt "Please enter correct Gateway:"

}

# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "up"}

# Remove any existing IP and gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
    $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}

If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}

 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
    -AddressFamily $IPType `
    -IPAddress $IP `
    -PrefixLength $MaskBits `
    -DefaultGateway $Gateway

# Configure the DNS server(s) IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses ($DNS, $DNS2)

#***** YOUR RDP SESSION WILL DROP, on your local windows machine, type into cmd: IPCONFIG /FLUSHDNS, then reconnect*****

#***** If you accidentally type the wrong IP or gateway, you must set the network back to dhcp then reboot and re-assign IP*****

#Wait 30seconds until network config is done so that below Trend Micro install can find the network path
Write-output "The script will now halt for 15 seconds to allow the network to refresh before disabling NIC power management and then installing Trend Micro. Your RDP Session may drop temporarily"
Start-Sleep -Seconds 15
}

#Disable Power Management on NIC
If ($checkboxNICPower.Checked -eq $true){
$adapters = Get-Netadapter -physical

foreach ($a in $adapters)
{
    $pnp = $a | Get-NetAdapterAdvancedProperty -RegistryKeyword "PnPCapabilities" -AllProperties
    
    if (!($pnp))
    {
        #need to add value, set to 280
        $new = 280
        $a | New-NetAdapterAdvancedProperty -RegistryKeyword "PnPCapabilities" -RegistryValue $new -RegistryDataType REG_DWORD
        $a | restart-netadapter

    }
    elseif (([int]"$($pnp.RegistryValue)" -band 24) -eq 0)
    {
        #power is not disabled, take current value and add 24
        $new = [int]"$($pnp.RegistryValue)" -bor 24
        $a | Remove-NetAdapterAdvancedProperty -RegistryKeyword "PnPCapabilities" -AllProperties
        $a | New-NetAdapterAdvancedProperty -RegistryKeyword "PnPCapabilities" -RegistryValue $new -RegistryDataType REG_DWORD
        $a | restart-netadapter
    }
    elseif (([int]"$($pnp.RegistryValue)" -band 24) -eq 24)
    {
        #power saving is disabled, we are good
    }
    else
    {
        #unknown setting state, leave alone
    }
#***** YOUR RDP SESSION WILL DROP FOR 3-5 SECONDS AND RECONNECT AUTOMATICALLY*****

Start-Sleep -Seconds 15
Write-output "Power Management has been disabled on the NIC, script will halt for 15 seconds"
}
}

#Activate Windows
If ($checkboxActivate.Checked -eq $true){
$computer = Get-Content env:computername

$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer

$service.InstallProductKey($textKey.text)

$service.RefreshLicenseStatus()

Write-output "Windows was activated"
}

#Install Trend Micro (For US)
#currently not working as a way to disable security prompt: Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.contoso.net" -Force
#If ($checkboxTrend.Checked -eq $true){
#Start-Process -FilePath '\\sanitized\Software\Trend Micro\2019\TMx64Silent.exe'
#Give time for Trend Micro to complete before starting windows updates, this will prevent an unexpected reboot that would interrupt Trend install
#Write-output "The script will now halt for 15 minutes to allow Trend to install before beginning windows updates"
#Start-Sleep -Seconds 900
#}

#Start windows updates with auto-reboot (this only installs one batch of updates, after each reboot it needs to be run again)
If ($checkboxUpdate.Checked -eq $true){
#Define update criteria.

$Criteria = "IsInstalled=0"

#Search for relevant updates.

$Searcher = New-Object -ComObject Microsoft.Update.Searcher

$SearchResult = $Searcher.Search($Criteria).Updates

#Notify of update starting
Write-output "Windows Updates will now be installed, the server will reboot automatically when necessary"

#Download updates.

$Session = New-Object -ComObject Microsoft.Update.Session

$Downloader = $Session.CreateUpdateDownloader()

$Downloader.Updates = $SearchResult

$Downloader.Download()


$Installer = New-Object -ComObject Microsoft.Update.Installer

$Installer.Updates = $SearchResult

$Result = $Installer.Install()


If ($Result.rebootRequired) { shutdown.exe /t 0 /r /f}
}