#Intune script logs path: \\laptop\c$\ProgramData\Microsoft\IntuneManagementExtension\Logs
#$env:AZCOPY_BUFFER_GB=8
#$env:AZCOPY_CONCURRENCY_VALUE=16

#$env:AZCOPY_CONCURRENCY_VALUE=16
$user = whoami.exe
$user = $user.Substring(9)
$i = 0

Start-Transcript -path "C:\Users\$user\$($user)output.txt" -append
          
$email = ([adsisearcher]"(samaccountname=$user)").FindOne().Properties.mail

Send-MailMessage -From "$email" -To 'quinn.favo@contoso.com' -Subject "Script started for $user" -SmtpServer "server.contoso.net"

$comp = $env:ComputerName

$files = "C:\$comp.csv"
$inputCsv = Import-Csv $files | Sort-Object * -Unique

$exists = Test-Path -path "C:\Users\$user\PSTMapping$user.csv"
if ($exists) {
    Remove-Item -Path "C:\Users\$user\PSTMapping$user.csv" -Verbose
}

$isOutlookOpen = Get-Process outlook*
if ($isOutlookOpen -eq $null) {
    # Outlook is already closed run code here:
    Write-Output "Outlook is already closed"

    Set-Location "C:\Program Files\"
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
            
            $fileName = $user + $i + ".pst"
            $onlineName = $user + $i
            $i++
            $source = "$($pst.directory)\$($pst.name)"
                
            Write-Output "Source is $source"
        
            $hash = [ordered]@{ Workload = 'Exchange' ; FilePath = '' ; Name = "$fileName" ; Mailbox = "$email" ; IsArchive = 'TRUE' ; TargetRootFolder = "$onlineName" ; ContentCodePage = '' ; SPFileContainer = '' ; SPManifestContainer = '' ; SPSiteUrl = '' }
            $newRow = new-object psobject -prop $hash
   
            Export-Csv -Path "C:\Users\$user\PSTMapping$user.csv" -inputobject $newrow -append -NoTypeInformation -Force

            .\azcopy make "https://pstrepository.blob.core.windows.net/$($user)?sv=URL HERE"

            .\azcopy copy "$source" "https://pstrepository.blob.core.windows.net/$($user)?sv=URL HERE" --log-level debug
        }
    }
}
else {
    $isOutlookOpen = Get-Process outlook*
    # while loop makes sure all outlook windows are closed before moving on to other code:
    while ($isOutlookOpen -ne $null) {
        Get-Process outlook* | ForEach-Object { $_.CloseMainWindow() | Out-Null }
        sleep 5
        If (($isOutlookOpen = Get-Process outlook*) -ne $null) {
            Write-Host "Outlook is Open.......Closing Outlook"
            $wshell = new-object -com wscript.shell
            $wshell.AppActivate("Microsoft Outlook")
            $wshell.Sendkeys("%(Y)")
            $isOutlookOpen = Get-Process outlook*
        }
    }
    #Outlook has been closed run code here:
    Write-Output "Outlook is closed"
    
    Set-Location "C:\Program Files\"
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
            
            $fileName = $user + $i + ".pst"
            $onlineName = $user + $i
            $i++
            $source = "$($pst.directory)\$($pst.name)"
                
            Write-Output "Source is $source"
        
            $hash = [ordered]@{ Workload = 'Exchange' ; FilePath = '' ; Name = "$fileName" ; Mailbox = "$email" ; IsArchive = 'TRUE' ; TargetRootFolder = "$onlineName" ; ContentCodePage = '' ; SPFileContainer = '' ; SPManifestContainer = '' ; SPSiteUrl = '' }
            $newRow = new-object psobject -prop $hash
   
            Export-Csv -Path "C:\Users\$user\PSTMapping$user.csv" -inputobject $newrow -append -NoTypeInformation -Force

                        .\azcopy make "https://pstrepository.blob.core.windows.net/$($user)?sv=URL HERE"

            .\azcopy copy "$source" "https://pstrepository.blob.core.windows.net/$($user)?sv=URL HERE" --log-level debug
        }
    }
}
.\azcopy copy "C:\Users\$user\PSTMapping$user.csv" "URL HERE"
Stop-Transcript
.\azcopy copy "C:\Users\$user\$($user)output.txt" "URL HERE"