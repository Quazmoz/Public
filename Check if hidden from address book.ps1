Get-ADUser `
 -Filter {(enabled -eq "false") -and (msExchHideFromAddressLists -notlike "*")} `
 -SearchBase "OU=Contoso,DC=contoso,DC=net"`
 -Properties enabled,msExchHideFromAddressLists | Out-File C:\Users\qmfavo\Desktop\filename1.txt

