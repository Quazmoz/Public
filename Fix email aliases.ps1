Start-Transcript -Path "C:\transcripts\transcript0.txt"

#run these first
$emails = Get-Mailbox -ResultSize Unlimited
$emails.PrimarySmtpAddress | Format-List > "C:\Users\favo\Desktop\smtp.txt"
$emails.EmailAddresses | Format-List > "C:\Users\favo\Desktop\allemails.txt"
$DL = Get-DistributionGroup -ResultSize Unlimited
$DL.EmailAddresses | Format-List > "C:\Users\favo\Desktop\DLs.txt"

#then this to check the emails that you will be modifying
Foreach ($email in $emails) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*consotos*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*") {
        $filteredEmail = $email.EmailAddresses.SmtpAddress | Where-Object { $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*consotos*" -and $_ -notlike "*contoso*" }
        Add-Content -Path C:\Users\favo\Desktop\badAliases.txt -Value $filteredEmail
        Write-Output "$($email.PrimarySMTPaddress) has a bad alias"
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\badMailboxes.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodMailboxes.txt -Value $email.PrimarySmtpAddress
    }
}

Foreach ($email in $DL) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*consotos*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*") {
        $filteredEmail = $email.EmailAddresses.SmtpAddress | Where-Object { $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*consotos*" -and $_ -notlike "*contoso*" }
        Add-Content -Path C:\Users\favo\Desktop\badDLAliases.txt -Value $filteredEmail
        Write-Output "$($email.PrimarySMTPaddress) has a bad alias"
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\badDLs.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodDLs.txt -Value $email.PrimarySmtpAddress
    }
}


#then run this to actually modify the aliases
Foreach ($email in $emails) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*consotos*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*") {
        $filteredEmail = $email.EmailAddresses.SmtpAddress | Where-Object { $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*consotos*" -and $_ -notlike "*contoso*" }
        Add-Content -Path C:\Users\favo\Desktop\removedAliases.txt -Value $filteredEmail
        Foreach ($alias in $filteredEmail) {
            $email | Set-mailbox -EmailAddresses @{remove = $alias }
            Write-Output "Removed $alias"
        }
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\modifiedMailboxes.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodMailboxes.txt -Value $email.PrimarySmtpAddress
    }
}

Foreach ($email in $DL) {
    If ($email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*" -and $email.emailaddresses.Smtpaddress -notlike "*consotos*" -and $email.emailaddresses.Smtpaddress -notlike "*contoso*") {
        $filteredEmail = $email.EmailAddresses.SmtpAddress | Where-Object { $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*consotos*" -and $_ -notlike "*contoso*" }
        Add-Content -Path C:\Users\favo\Desktop\removedDLAliases.txt -Value $filteredEmail
        Foreach ($alias in $filteredEmail) {
            $email | Set-DistributionGroup -EmailAddresses @{remove = $alias }
            Write-Output "Removed $alias"
        }
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\favo\Desktop\modifiedDLs.txt -Value $output2
    }
    else {
        Add-Content -Path C:\Users\favo\Desktop\goodDLs.txt -Value $email.PrimarySmtpAddress
    }
}

Stop-Transcript

#testing
#dont run these
If ($email.EmailAddresses.SmtpAddress -notlike "*contoso.com" -and $email.EmailAddresses.SmtpAddress -notlike "*contoso.onmicrosoft.com") {
    Write-Output "$($email.EmailAddresses.SmtpAddress) has a bad email alias"
    $output2 = "$($email.PrimarySmtpAddress)"
    Add-Content -Path C:\Users\favo\Desktop\emailswith.txt -Value $output2
}
else {
    Add-Content -Path C:\Users\favo\Desktop\emailswithout.txt -Value $email.PrimarySmtpAddress
}

#test
Foreach ($email in $emails) {
    
    $filteredEmail = $email.EmailAddresses.SmtpAddress | Where-Object { $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*contoso*" -and $_ -notlike "*consotos*" -and $_ -notlike "*contoso*" }
    Write-Output $filteredEmail
    
}

#remove bad aliases
$emailchange = Get-content -Path C:\Users\favo\Desktop\badMailboxes.txt
Foreach ($tochange in $emailchange) {
    $mailbox = Get-Mailbox -Identity $tochange
    $address = $mailbox.alias
    $mailbox | Set-mailbox -EmailAddresses @{remove = "$address" }
}

#add contoso.com alias to DLs
$DLchange = Get-content -Path C:\Users\favo\Desktop\DLwithout.txt
Foreach ($tochange in $DLchange) {
    $DGroup = Get-DistributionGroup -Identity $tochange
    $DGaddress = $DGroup.alias + "@contoso.com"
    $DGroup | Set-DistributionGroup -EmailAddresses @{add = "$DGaddress" }
}

$localAliases = Get-Content C:\Users\favo\Desktop\emailswith.txt
#test
Foreach ($alias in $localAliases) {
    $alias = Get-Mailbox $alias
    Write-Output "New user"
    $filteredAliases = $alias.EmailAddresses.SmtpAddress | Where-Object { $_ -notlike "*.local*" }
    Write-Output $filteredAliases
}