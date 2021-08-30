# ***This must be run with outlook closed***
#Parameters (must be changed depending on user)
$Account = "quinn.favo@contosona.com"
$Folder = "Inbox"
#Variable used to search the body of emails for VDP alerts
$BodySearch = "*VMware vSphere Data Protection*"
#Counter for how many emails were received from VDP
$EmailCheck = 0
#Change this based on Europe or CNA
$SendCheck = "IT Reports"

#Create outlook COM object to search folders
$Outlook = New-Object -ComObject Outlook.Application
$OutlookNS = $Outlook.GetNamespace("MAPI")

#Get all emails from specific account and folder
$AllEmails = $OutlookNS.Folders.Item($Account).Folders.Item($Folder).Items
#Filter to emails with attachments and specific subject line (-match uses RegEx)
$ReportsEmails = $AllEmails | ? { ($_.HTMLBody -like $BodySearch) -and ($_.SenderName -match $SendCheck ) }
#Count number of emails received
$ReportsEmails | ForEach-Object {$EmailCheck = $EmailCheck + 1}

Write-Output $EmailCheck
$ReportsEmails |  Out-File C:\Users\qmfavo\Desktop\emails.txt

#Quit Outlook COM Object
$Outlook.Quit()

#Kill Outlook after finishing script(allows you to open outlook again)
Stop-Process -Name "OUTLOOK" -Force