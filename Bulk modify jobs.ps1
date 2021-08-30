
$jobs = Get-VBRJob | Where-Object { $_.name -notlike ("*copy*") }

foreach ($myJob in $jobs) {
    Set-VBRJobAdvancedStorageOptions -Job $myJob -CompressionLevel 6
}


#get proxies assigned to jobs
Get-VBRJobProxy

#get proxies and assign to var
$myJob = $jobs[1]
$sourceProxies = $myjob | Get-VBRJobProxy
#Get-VBRViProxy

foreach ($myJob in $jobs) {
    $myjob | Set-VBRJobProxy -Proxy $sourceProxies
}


Set-VBRJob -Job $myjob -SourceWANAccelerator USLTAP100 -TargetWANAccelerator USPGBS001

#fix

$jobs = Get-VBRJob | Where-Object { ($_.name -notlike ("*copy*")) -and ($_.name -notlike ("*pg*")) -and ($_.name -notlike ("*semcan*")) -and ($_.name -notlike ("*automation*")) }

foreach ($myJob in $jobs) {
    $repo = Get-VBRBackupRepository | where {$_.id -eq $myJob.Info.TargetRepositoryId} | select name
    Write-Output $repo.name
    $repoProxy = Get-VBRViProxy | where {$_.name -eq $repo.name}
    $myJob | Set-VBRJobProxy -Proxy $repoProxy
}


#test

Get-VBRViProxy | where {$_.name -eq $repo.name}

$Job = Get-VBRJob -name "Server1"
$repo = Get-VBRBackupRepository | where {$_.id -eq $Job.Info.TargetRepositoryId} | select name

#not working
$job = Get-VBRComputerBackupJob -Name $myJob.name
    $options = New-VBRStorageOptions -CompressionLevel High -StorageOptimizationType LanTarget
    Set-VBRStorageOptions -Options $options -CompressionLevel High -StorageOptimizationType LANTarget
    