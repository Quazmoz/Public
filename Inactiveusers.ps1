#This must be run in a new elevated powershell window, if it is run a second time in the same window it may have errors

Install-Module ImportExcel

$exceldoc = Import-Excel -Path C:\Users\QMFAVO\Desktop\Inactive.xlsx

$count = 0
$array = @()

#Iterate through each user
ForEach ($person in $exceldoc.USERID){
    #Re-initialize $user variable to clear the value assigned by each iteration of the ForEach loop
    $user = $null
    #Get ADuser object from AD
    $user = Get-ADuser $person

#If no user found, the variable is null and will go through this if statement
if ($user -eq $null){
    $array += "Deleted"
}
#Otherwise will run one of the below
else{
        If ($user.enabled -eq "True"){
        $array += "Enabled"
        
        }
        else {
        $array += "Disabled"
        
        }
}

$count += 1

}
#Error checking to make sure it checked all users
Write-output $count
$array | Out-file C:\Users\qmfavo\Desktop\statuses.txt

$exceldoc | Export-Excel -Path C:\Users\QMFAVO\Desktop\Inactivemodified.xlsx