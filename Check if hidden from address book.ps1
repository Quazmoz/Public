Get-ADUser `
 -Filter {(enabled -eq "false") -and (msExchHideFromAddressLists -notlike "*")} `
 -SearchBase "OU=Carmeuse,DC=carmeuse,DC=net"`
 -Properties enabled,msExchHideFromAddressLists | Out-File C:\Users\qmfavo\Desktop\filename1.txt