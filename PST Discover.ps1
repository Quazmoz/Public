#for footprints check
#PowerShell.exe -ExecutionPolicy UnRestricted -File "C:\Program Files\PST Discover.ps1"

#local PST check
Start-Transcript -path C:\output.txt -append
  
$comp = $env:ComputerName
Write-Output $comp
$exists = Test-Path -path "C:\$comp.csv"
if($exists){
    Remove-Item -Path "C:\$comp.csv"
}
#$comp = $comp.Substring(9)
Get-ChildItem -Recurse -Force c:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.pst*") } | Select-Object Name,Directory,Length| Export-Csv -Encoding UTF8 "C:\$comp.csv" -nti -append
Get-ChildItem -Recurse -Force p:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.pst*") } | Select-Object Name,Directory,Length| Export-Csv -Encoding UTF8 "C:\$comp.csv" -nti -append
Get-ChildItem -Recurse -Force h:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.pst*") } | Select-Object Name,Directory,Length| Export-Csv -Encoding UTF8 "C:\$comp.csv" -nti -append
Get-ChildItem -Recurse -Force d:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.pst*") } | Select-Object Name,Directory,Length| Export-Csv -Encoding UTF8 "C:\$comp.csv" -nti -append
Get-ChildItem -Recurse -Force u:\ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.pst*") } | Select-Object Name,Directory,Length| Export-Csv -Encoding UTF8 "C:\$comp.csv" -nti -append

robocopy C:\ '\\server\PST Checker' "$comp.csv" /mt /z
Stop-Transcript