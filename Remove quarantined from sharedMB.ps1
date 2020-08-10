Out-file C:\Users\qmfavo\Desktop\statuses.txt

Get-ActiveSyncDevice -filter {deviceaccessstate -eq 'quarantined'} | Out-file C:\Users\qmfavo\Desktop\quarantined.txt

Get-ActiveSyncDevice -filter {deviceid -eq 'BC35A7G5B56VJ2D11RR29CM3QK'} | Out-file C:\Users\qmfavo\Desktop\quarantinedtest.txt