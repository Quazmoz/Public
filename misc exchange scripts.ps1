#set permissions for calendar only, switch to give access to private items usually needed as below also
Add-MailboxFolderPermission -Identity john.smith@contoso.com:\Calendar -User quinn.favo@constoso.com -AccessRights Editor

#Enable User for skype directly on the skype server, fix permissions/config
Enable-csuser -Identity contoso\JSMITH -Sipaddress SIP:JSMITH@contoso.net -RegistrarPool eur-skype-pool.contoso.net
Grant-CsConferencingPolicy -identity contoso\JSMITH -PolicyName "Enterprise CAL - VoIP Only"
Grant-CsExternalAccessPolicy -Identity contoso\JSMITH -PolicyName "Enabled external access"
Grant-CsMobilityPolicy -Identity contoso\JSMITH -PolicyName "Allow connection from smart devices"

Get-csuser -Identity contoso\bdesmarets

#add a delegate in skype for business
Set-CsUser -Delegates @{add='karen.dicaprio@contoso.com'} -User "thomassibo@contoso.com"

#allow conflicts on a shared calendar
Set-CalendarProcessing -Identity "MyCalendar" -AllowConflicts $true

#Add send-as permissions on a shared mailbox
Set-Mailbox "APInquiry" -GrantSendOnBehalfTo @{add="APFastEntry"}

#Get all mail contacts that are not hidden from the address book
$DesktopPath = [Environment]::GetFolderPath("Desktop")
Get-Mailcontact -Resultsize Unlimited -Filter {HiddenFromAddressListsEnabled -eq $false} | Select identity,alias,HiddenFromAddressListsEnabled | Export-Csv -Path $DesktopPath\NotHiddenContacts.csv -NoTypeInformation

#check permissions
Get-Mailbox "APInquiry" | Select -ExpandProperty GrantSendOnBehalfTo | Select Name,Parent

Set-MailboxAutoReplyConfiguration -Identity MBROWN -AutoReplyState Enabled -InternalMessage "This email is no longer active, please email John Smith: jsmith@contoso.com"

#Get all DLs with members
$desktop = [Environment]::GetFolderPath("Desktop")
$saveto = "$desktop\dlmembers.csv"

Get-DistributionGroup -ResultSize Unlimited | sort name | ForEach-Object {

	"`r`n$($_.Name)`r`n=============" | Add-Content $saveto
	Get-DistributionGroupMember $_ | sort Name | ForEach-Object {
		If($_.RecipientType -eq "UserMailbox")
			{
				$_.Name + ", (" + $_.PrimarySMTPAddress + ")" | Add-Content $saveto
			}
	}
}