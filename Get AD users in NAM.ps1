$users = Get-ADUser -Filter {EmailAddress -like "*@*"} -Properties * -SearchBase "OU=NAM,OU=contoso,DC=contoso,DC=net"

$DesktopPath = [Environment]::GetFolderPath("Desktop")

$users.samaccountname > $DesktopPath\samaccounts.txt
$users.emailaddress > $DesktopPath\emails.txt
$users.displayname > $DesktopPath\displayname.txt
$users.givenname > $DesktopPath\firstname.txt
$users.sn > $DesktopPath\lastname.txt

$users.alias

$users | Select-Object -Property samaccountname,emailaddress,displayname,givenname,sn |
  Export-Csv $DesktopPath\Exported.csv

$localCredential = Get-Credential
 
@(Get-AdComputer -Filter *).foreach({
 
   $output = @{ ComputerName = $_.Name }
 
   if (-not (Test-Connection -ComputerName $_.Name -Quiet -Count 1)) { $output.Status = 'Offline'
   } else {
       $trustStatus = Invoke-Command -ComputerName $_.Name -ScriptBlock { Test-ComputerSecureChannel } -Credential $localCredential
       $output.Status = $trustStatus
   }
 
   [pscustomobject]$output
 
})

Reset-ComputerMachinePassword -Server server1 -Credential (Get-Credential)

$computername = 'computer1'

$instance = Get-CimInstance -ComputerName $computername -ClassName 'Win32_ComputerSystem'

$invCimParams = @{
    MethodName = 'UnjoinDomainOrWorkGroup'
    Arguments = @{ FUnjoinOptions=0;Username="user";Password="password" }
}
$instance | Invoke-CimMethod @invCimParams

$Groups = (Get-ADuser -Identity jsmith -Properties memberof).memberof 
$Groups | Get-ADGroup | Select-Object name | Sort-Object name