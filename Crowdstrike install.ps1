$compGroups = ([adsisearcher]"(&(objectCategory=computer)(cn=$env:COMPUTERNAME))").FindOne().Properties.memberof -replace '^CN=([^,]+).+$', '$1'

foreach ($group in $compGroups) {
    if ($group -like "*GLB-CrowdStrike-Falcon-Installation*") {
        $installed = Test-Path "C:\Windows\System32\drivers\CrowdStrike"
        if ($installed -eq $false) {
            cd "\\contoso.net\NETLOGON\cs\"
            .\WindowsSensor.exe /install /quiet /norestart CID=00EAC087B6734C45AD9B1E21A2B2C04E-2C
            #start-process "\\contoso.net\NETLOGON\cs\windowssensor.exe"
        }
    }
}
