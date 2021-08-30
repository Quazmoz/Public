#For footprints
# PowerShell.exe -ExecutionPolicy UnRestricted -File "C:\Program Files\Install Visio and Project.ps1"

$isWordOpen = Get-Process winword*
while ($isWordOpen -ne $null) {
    Get-Process winword* | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    sleep 5
    If (($isWordOpen = Get-Process winword*) -ne $null) {
        Write-Host "Word is Open.......Closing Word"
        $wshell = new-object -com wscript.shell
        $wshell.AppActivate("Save your changes to this file")
        $wshell.Sendkeys("%(S)")
        $isExcelOpen = Get-Process winword*
    }
}

<# $isOneDriveOpen = Get-Process OneDrive*

    # while loop makes sure onedrive is closed before moving on to other code:
    while ($isOneDriveOpen -ne $null) {
        Get-Process OneDrive* | ForEach-Object { $_.CloseMainWindow() | Out-Null }
        sleep 5
        If (($isOneDriveOpen = Get-Process OneDrive*) -ne $null) {
            Write-Host "OneDrive is Open.......Closing OneDrive"
            $wshell = new-object -com wscript.shell
            $isOneDriveOpen = Get-Process onedrive*
        }
    } #>

$isExcelOpen = Get-Process excel*
while ($isExcelOpen -ne $null) {
    Get-Process excel* | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    sleep 5
    If (($isExcelOpen = Get-Process excel*) -ne $null) {
        Write-Host "Excel is Open.......Closing Excel"
        $wshell = new-object -com wscript.shell
        $wshell.AppActivate("Microsoft Excel")
        $wshell.Sendkeys("%(S)")
        $isExcelOpen = Get-Process excel*
    }
}

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

$isOneNoteOpen = Get-Process onenote

# while loop makes sure all windows are closed before moving on to other code:
while ($isOneNoteOpen -ne $null) {
    Get-Process onenote* | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    sleep 5
    If (($isOneNoteOpen = Get-Process onenote) -ne $null) {
        Write-Host "OneNote is Open.......Closing OneNote"
        $wshell = new-object -com wscript.shell
        $wshell.AppActivate("Microsoft OneNote")
        #$wshell.Sendkeys("%(Y)")
        $isOneNoteOpen = Get-Process onenote
    }
}

$isSkypeOpen = Get-Process lync

# while loop makes sure all windows are closed before moving on to other code:
while ($isSkypeOpen -ne $null) {
    Get-Process lync | kill
    sleep 5
    If (($isSkypeOpen = Get-Process lync) -ne $null) {
        Write-Host "Skype is Open.......Closing Skype for Business"
        
        $isSkypeOpen = Get-Process lync
    }
}



#command to manually install visio
Set-Location "\\server\Visio0365\"

./setup.exe /configure visio.xml

Start-Sleep -Seconds 1800

#command to manually install project
Set-Location "\\server\Project0365\"

./setup.exe /configure project.xml
