#Get-Mailbox | Format-List > "C:\Users\admqmfavo\Desktop\conflicts.txt"

#run these first
$emails = Get-Mailbox -ResultSize Unlimited
$emails.PrimarySmtpAddress | Format-List > "C:\Users\admqmfavo\Desktop\smtp.txt"
$emails = Get-Mailbox -ResultSize Unlimited
$emails.EmailAddresses | Format-List > "C:\Users\admqmfavo\Desktop\allemails.txt"
$DL = Get-DistributionGroup -ResultSize Unlimited
$DL.EmailAddresses | Format-List > "C:\Users\admqmfavo\Desktop\DLs.txt"


#Then run this and the other just like it below for the DLs
Foreach ($email in $emails){
    
    #Write-Output $email.PrimarySmtpAddress
    If ($email.PrimarySmtpAddress.Domain -like "contosona*"){
        Write-Output $email.PrimarySmtpAddress
        #$output1 = $email.PrimarySmtpAddress
        #Add-Content -Path C:\Users\admqmfavo\Desktop\emailswithout.txt -Value $output1
        If ($email.EmailAddresses.SmtpAddress -like "*contoso.com"){
        Write-Output "$($email.EmailAddresses.SmtpAddress) has a contoso.com email alias"
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\admqmfavo\Desktop\emailswith.txt -Value $output2
        }else{
            Add-Content -Path C:\Users\admqmfavo\Desktop\emailswithout.txt -Value $email.PrimarySmtpAddress
        }
    }
}

Foreach ($email in $DL){
    
    #Write-Output $email.PrimarySmtpAddress
    If ($email.PrimarySmtpAddress.Domain -like "contosona*"){
        Write-Output $email.PrimarySmtpAddress
        #$output1 = $email.PrimarySmtpAddress
        #Add-Content -Path C:\Users\admqmfavo\Desktop\emailswithout.txt -Value $output1
        If ($email.EmailAddresses.SmtpAddress -like "*contoso.com"){
        Write-Output "$($email.EmailAddresses.SmtpAddress) has a contoso.com email alias"
        $output2 = "$($email.PrimarySmtpAddress)"
        Add-Content -Path C:\Users\admqmfavo\Desktop\DLwith.txt -Value $output2
        }else{
            Add-Content -Path C:\Users\admqmfavo\Desktop\DLwithout.txt -Value $email.PrimarySmtpAddress
        }
    }
}

#Then run these to add alias

#add contoso.com alias to emails
$emailchange = Get-content -Path C:\Users\admqmfavo\Desktop\emailswithout.txt
Foreach ($tochange in $emailchange){
    $mailbox = Get-Mailbox -Identity $tochange
    $address = $mailbox.alias + "@contoso.com"
    $mailbox | Set-mailbox -EmailAddresses @{add="$address"}
}

#add contoso.com alias to DLs
$DLchange = Get-content -Path C:\Users\admqmfavo\Desktop\DLwithout.txt
Foreach ($tochange in $DLchange){
    $DGroup = Get-DistributionGroup -Identity $tochange
    $DGaddress = $DGroup.alias + "@contoso.com"
    $DGroup | Set-DistributionGroup -EmailAddresses @{add="$DGaddress"}
}

$testing = Get-Content -Path C:\Users\admqmfavo\Desktop\emailswithout.txt
$testing2 = Get-Content -Path C:\Users\admqmfavo\Desktop\emailswith.txt
$i = 0
Foreach ($test in $testing){
    If ($test -like $testing2[$i]){
        Write-Output "$test is good"
    }
    else {
        Write-Output "$test needs contoso.com"
        $i --
    }
    $i ++
}