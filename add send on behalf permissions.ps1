#give permission to send on behalf

Get-Mailbox User@contoso.com | set-mailbox -GrantSendOnBehalfto @{Add="User@contoso.com"}

# check permissions
get-Mailbox USPG-Receptionist@contoso.com | Select-Object displayname,grantsendonbehalfto | ft  -a