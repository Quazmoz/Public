$DesktopPath = [Environment]::GetFolderPath("Desktop")
$Servers = Get-content $DesktopPath\Servers.txt

Foreach ($Server in $Servers){
    #ping -n 1 $Server
    nslookup $Server

}