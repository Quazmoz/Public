Start-Transcript -Path "C:\transcripts\transcriptShared.txt"

#run these first
$emails = Get-Mailbox -ResultSize Unlimited
$emails.PrimarySmtpAddress | Format-List > "C:\Users\favo\Desktop\smtp.txt"
$emails.EmailAddresses | Format-List > "C:\Users\favo\Desktop\allemails.txt"
$sharedEmails = Get-Mailbox -RecipientTypeDetails SharedMailbox

#then this to check the emails that you will be modifying
Foreach ($email in $emails) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso.mail.onmicrosoft.com*") {

        Write-Output "$($email.PrimarySMTPaddress) is missing contoso.mail.onmicrosoft.com"
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\badMailboxes.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodMailboxes.txt -Value $email.PrimarySmtpAddress
    }
}

Foreach ($email in $sharedEmails) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso.mail.onmicrosoft.com*") {
        Write-Output "$($email.PrimarySMTPaddress) is missing contoso.mail.onmicrosoft.com"
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\badSharedMailboxes.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodSharedMailboxes.txt -Value $email.PrimarySmtpAddress
    }
}


#then run this to actually modify the aliases
Foreach ($email in $emails) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso.mail.onmicrosoft.com*") {
        $alias = $email.alias + "@contoso.mail.onmicrosoft.com"
            $email | Set-mailbox -EmailAddresses @{add = $alias }
            Write-Output "Added $alias"
        
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\modifiedMailboxes.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodMailboxes.txt -Value $email.PrimarySmtpAddress
    }
}

Foreach ($email in $sharedEmails) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso.mail.onmicrosoft.com*") {
        $alias = $email.alias + "@contoso.mail.onmicrosoft.com"
        $email | Set-mailbox -EmailAddresses @{add = $alias }
        Write-Output "Added $alias"
        
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\modifiedSharedMailboxes.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodSharedMailboxes.txt -Value $email.PrimarySmtpAddress
    }
}

Stop-Transcript