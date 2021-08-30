#run this chunk first
Import-Module ServerManager
Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
# run this chunk next
$driveLetter = Read-Host -Prompt "What letter is used for the homedrive? (for example, P drive, E drive, H drive, etc)"
# run this last chunk
Set-Location "${driveLetter}:"
$i = 0
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

$comp = $env:ComputerName

$folders = Get-ChildItem -Path "${driveLetter}:\" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

$user = Read-Host -Prompt "What user should have their pst files uploaded? (for example, John Smith)"


$first, $last = $user -split " "
$displayName = "$last $first"
$ADUser = Get-ADUser -Filter { displayName -like $displayName } -Properties *
$sam = $ADUser.samaccountname
$csvName = $comp + $sam

$exists = Test-Path -path "C:\PSTMapping$sam.csv"
if ($exists) {
    Remove-Item -Path "C:\PSTMapping$sam.csv" -Verbose -Force
}
$exists = Test-Path -path "C:\$csvName.csv"
if ($exists) {
    Remove-Item -Path "C:\$csvName.csv" -Verbose -Force
}
#run only whichever is needed from the two csv builders below
#US
Get-ChildItem -Recurse -Force p:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and ( $_.Name -like "*.pst*") -and ($_.Name -notlike "*tmp*") -and ($_.Directory -like "*$user*") } | Select-Object Name, Directory, Length | Export-Csv "C:\$csvName.csv" -nti -append

#EUR
Get-ChildItem -Recurse -Force f:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and ( $_.Name -like "*.pst*") -and ($_.Name -notlike "*tmp*") -and ($_.Directory -like "*$user*") } | Select-Object Name, Directory, Length | Export-Csv "C:\$csvName.csv" -nti -append

#then finally run this
$files = "C:\$csvName.csv"
$inputCsv = Import-Csv $files | Sort-Object * -Unique
Set-Location "C:\"
.\azcopy make "https://pstrepository.blob.core.windows.net/$($sam)?sv=URL HERE"
foreach ($pst in $inputCsv) {
    $next = $false

    if ($pst.length -like "271360") {
        write-output "not changing $($pst.name)"
        $next = $true
    }

    if ($pst.length -like "131072") {
        write-output "not changing $($pst.name)"
        $next = $true
    }

    if ($pst.length -like "0") {
        write-output "not changing $($pst.name) because it is zero"
        $next = $true
    }

    if ($pst.name -like "*Recycle.bin*") {
        write-output "not changing $($pst.name) because it is in the recycle bin"
        $next = $true
    }

    if ($pst.directory -like '*Corel*') {
        write-output "not changing $($pst.name) because it is not a PST file (Corel document)"
        $next = $true
    }
    if ($next -eq $true) { Write-Output "Moving onto next one because $($pst.name) is not an actual PST file" }
    else {

        
        $fileName = $sam + $i + ".pst"
        $onlineName = $sam + $i
        $email = $ADUser.emailaddress
        $i++
        $source = "$($pst.directory)\$($pst.name)"
            
        Write-Output "Source is $source"
    
        $hash = [ordered]@{ Workload = 'Exchange' ; FilePath = '' ; Name = "$fileName" ; Mailbox = "$email" ; IsArchive = 'TRUE' ; TargetRootFolder = "$onlineName" ; ContentCodePage = '' ; SPFileContainer = '' ; SPManifestContainer = '' ; SPSiteUrl = '' }
        $newRow = new-object psobject -prop $hash

        Export-Csv -Path "C:\PSTMapping$sam.csv" -inputobject $newrow -append -NoTypeInformation -Force

        .\azcopy copy "$source" "https://pstrepository.blob.core.windows.net/$($sam)?sv=URL HERE"

    }
}
.\azcopy copy "C:\PSTMapping$sam.csv" "https://pstrepository.blob.core.windows.net/mappingfiles?sv= URL HERE"
