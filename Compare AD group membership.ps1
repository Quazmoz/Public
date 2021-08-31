$GroupName1 = 'Group1'
$GroupName2 = 'Group2'

$Group1Members = Get-ADGroupMember $GroupName1 | select -ExpandProperty samaccountname
$Group2Members = Get-ADGroupMember $GroupName2 | select -ExpandProperty samaccountname

Compare-Object $Group1Members $Group2Members -IncludeEqual | select @{n="samAccountName";e={$_.inputobject}}, @{n="Groups";e={if($_.sideindicator -eq '<='){'Only Group 1'}elseif($_.sideindicator -eq '=>'){'Only Group 2'}elseif($_.sideindicator -eq '=='){'Both Groups'}}}

$Group1Members = Get-ADGroupMember "Group1" | select -ExpandProperty samaccountname
foreach ($sam in $Group1Members) {
    $user = Get-ADuser $sam -Properties mail
    
       $hash = [ordered]@{ Email = "$($user.mail)" ;}
            $newRow = new-object psobject -prop $hash
   
            Export-Csv -Path "C:\Temp\maillist.csv" -inputobject $newrow -append -NoTypeInformation -Force
    #$user.mail | Export-Csv -Path C:\Temp\maillist.csv -Append
    Write-Output $user.mail
}
