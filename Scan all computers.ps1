#test
$computers = Get-ADComputer -filter *  | Select -Exp Name

$filenames = Get-Content "C:\Users\favo\Desktop\files.txt"

foreach ($computer in $computers) {

foreach ($filename in $filenames) {
Get-ChildItem -Recurse -Force \\uspgul706\c$, \\uspgul706\d$ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.$filename*") } | Select-Object Name,Directory| Export-Csv C:\Users\favo\Desktop\FoundFiles2.csv -nti -append
}

}

#get password docs
$computers = Get-ADComputer -filter *  | Select -Exp Name

$filenames = Get-Content "C:\Users\favo\Desktop\passwordCheck.txt"

foreach ($computer in $computers) {

foreach ($filename in $filenames) {
Get-ChildItem -Recurse -Force \\$computer\c$, \\$computer\d$ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*$filename*") } | Select-Object Name,Directory| Export-Csv C:\Users\favo\Desktop\FoundFiles2.csv -nti -append
}

}

#laptops PST check over network

$computers = Get-ADComputer -filter *  | Select -Exp Name

$computers = @($computers) -like '*ul*'

$filenames = Get-Content "C:\Users\favo\Desktop\files.txt"

foreach ($computer in $computers) {

foreach ($filename in $filenames) {
Get-ChildItem -Recurse -Force \\$computer\c$, \\$computer\d$ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.$filename*") } | Select-Object Name,Directory,Length| Export-Csv C:\Users\favo\Desktop\FoundFiles.csv -nti -append
}

}

#desktops PST Check over network
$computers = Get-ADComputer -filter *  | Select -Exp Name

$computers = @($computers) -like '*ud*'

$filenames = Get-Content "C:\Users\favo\Desktop\files.txt"

foreach ($computer in $computers) {

foreach ($filename in $filenames) {
Get-ChildItem -Recurse -Force \\$computer\c$, \\$computer\d$ -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.$filename*") } | Select-Object Name,Directory,Length| Export-Csv C:\Users\favo\Desktop\FoundDesktopFiles.csv -nti -append
}

}