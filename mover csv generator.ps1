#run this chunk first
Import-Module ServerManager
Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
$tag = Read-Host -Prompt "What phrase would you like to tag this migration batch with? (usually you will put the date or batch name)"
# run this chunk next
$driveLetter = Read-Host -Prompt "What letter is used for the homedrive? (for example, P drive, E drive, H drive, etc)"
# run this last chunk
Set-Location "${driveLetter}:"

$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

$csvname = "moverio.csv"

$fileExists = Test-Path -Path $desktopPath\csv\$csvName

if($fileExists){
    Remove-Item -Path $desktopPath\csv\$csvName
}else {
    try{New-Item -Path "$desktopPath\csv\" -ItemType "directory"}
    catch{Write-output "Didn't create because directory already exists"}
}

$folders = Get-ChildItem -Path "${driveLetter}:\" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

#fix permissions so that you can run this script properly
foreach ($folder in $folders) {
    $acl=(Get-item "$($folder.fullName)").GetAccessControl('Access')
    $secName = whoami.exe
    $permType = "Full"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$secName","$permtype",'ContainerInherit, ObjectInherit','none','Allow')
    $acl.SetAccessRule($AccessRule)
$acl | Set-Acl "$($folder.fullName)"
    Write-Output $acl
}

#loop through and build csv file
foreach($name in $folders.fullname){
    $nameHolder = $name.Substring(3)
    $first,$last = $nameHolder -split " "
    $userspec = "$last $first"
    $user = Get-ADUser -Filter "Name -like '$userspec'" -Properties *
    Write-Output $user.name
    if ($user -notlike $null){
    $hash = [ordered]@{ "Source Path" = "/${driveLetter}:/$($nameHolder)" ; "Destination Path" = "https://contoso-my.sharepoint.com/personal/$($user.samaccountname)contoso/Documents/M365-ImportedPersonalFolder" ; Tags = "$tag"}
    $newRow = new-object psobject -prop $hash
    Export-Csv -Path "$desktopPath\csv\$csvName" -inputobject $newrow -append -NoTypeInformation -Force
    }
}

$moverService = Get-Service -name "MoverService"

if($moverService.Status -ne "Running"){
Start-Process -FilePath '\\server\Software\Mover.io\mover.1.3.5.0.msi'
Write-Output "Follow the prompts to install mover.io agent"
}

#for EUR
#run this chunk first
Import-Module ServerManager
Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
$tag = Read-Host -Prompt "What phrase would you like to tag this migration batch with? (usually you will put the date or batch name)"
# run this chunk next
$driveLetter = Read-Host -Prompt "What letter is used for the homedrive? (for example, P drive, E drive, H drive, etc)"
# run this last chunk
Set-Location "${driveLetter}:"

$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

$csvname = "moverio.csv"

$fileExists = Test-Path -Path $desktopPath\csv\$csvName

if($fileExists){
    Remove-Item -Path $desktopPath\csv\$csvName
}else {
    try{New-Item -Path "$desktopPath\csv\" -ItemType "directory"}
    catch{Write-output "Didn't create because directory already exists"}
}

$folders = Get-ChildItem -Path "${driveLetter}:\Homefolders\" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

#get for folder names with a period

foreach($name in $folders.fullname){
    $userspec = $name.Substring(15)    
    $first,$last = $userspec.Split(".")
    $userspec = "$last $first"
    $folderName = "$first.$last"
    $user = Get-ADUser -Filter "Name -like '$userspec'" -Properties *
    Write-Output $user.name
    if ($user -notlike $null){
    $hash = [ordered]@{ "Source Path" = "/${driveLetter}:/Homefolders/$($folderName)" ; "Destination Path" = "https://contoso-my.sharepoint.com/personal/$($user.samaccountname)contoso/Documents/M365-ImportedPersonalFolder" ; Tags = "$tag"}
    $newRow = new-object psobject -prop $hash
    Export-Csv -Path "$desktopPath\csv\withPeriod$csvName" -inputobject $newrow -append -NoTypeInformation -Force
    }
}

#get for folder names with UPN

foreach($name in $folders.fullname){
    $userspec = $name.Substring(15)
    
    try{$user = Get-ADUser $userspec -Properties *
    Write-Output $user.name
    if ($user -notlike $null){
    $hash = [ordered]@{ "Source Path" = "/${driveLetter}:/Homefolders/$($user.samaccountname)" ; "Destination Path" = "https://contoso-my.sharepoint.com/personal/$($user.samaccountname)contoso/Documents/M365-ImportedPersonalFolder" ; Tags = "$tag"}
    $newRow = new-object psobject -prop $hash
    Export-Csv -Path "$desktopPath\csv\fullName$csvName" -inputobject $newrow -append -NoTypeInformation -Force
    }
    }catch{}
}