#***This must be run with outlook closed***
#This script queries the CNA Support ticket assignment notification emails
#*** IMPORTANT Please clear any CNA support emails that contain Account Suspension Request and are an escalation rather than a ticket assignment notification
#You can also do this by creating a new folder and moving the emails you would like to process into it and then changing the below specified folder
#Parameters (must be changed depending on user)
$Account = "quinn.favo@contoso.com"
$Folder = "Inbox"
#Variable used to search the body of emails
$BodySearch = "*Account Termination*"
#Counter for how many emails were received that match the above parameters
$EmailCheck = 0

#Grab desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

#Create outlook COM object to search folders
$Outlook = New-Object -ComObject Outlook.Application
$OutlookNS = $Outlook.GetNamespace("MAPI")

#Get all emails from specific account and folder
$AllEmails = $OutlookNS.Folders.Item($Account).Folders.Item($Folder).Items
#Filter to emails with attachments and specific subject line
$ReportsEmails = $AllEmails | ? { ($_.HTMLBody -like $BodySearch)}

#Count number of emails received
$ReportsEmails | ForEach-Object {$EmailCheck = $EmailCheck + 1}

Write-Output $EmailCheck
$ReportsEmails.Body | Out-File $DesktopPath\emails.txt

#Quit Outlook COM Object
$Outlook.Quit()

#Kill Outlook after finishing script(allows you to open outlook again)
Stop-Process -Name "OUTLOOK" -Force

#Exchange CLI
#Save the emails.txt file to the desktop on BEMAMS101
#Run the below on exchange server with AD module installed(BEMAMS101)

#Grab desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

$TermUsers = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("UserID:") }
Write-Output $TermUsers
$Manager = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("@contoso.COM") }
Write-Output $Manager
$Ticket = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("17") }
Write-Output $Ticket

$Date = Get-Date
$i = 0

#Iterate through users pulled from ticket notification emails
ForEach ($UserID in $TermUsers) {
    $Var = 5
    Write-Output $UserID.substring(9)
    $Var = Get-ADUser $UserID.substring(9) -Properties *
    #Check if AD user exists
    If ($Var -ne 5) {
        #If enabled - disable account, modify description, forward email, and hide from Address Book
        If ($Var.Enabled = "True") {
            $Tick = $Ticket[$i]
            $Man = $Manager[$i]
            $Man = $Man.Substring(1)
            Set-ADUser $Var -Description "$($Var.Description) Quinn Favo disabled $Date ticket# $Tick" -Enabled $False
            Set-Mailbox -Identity $Var.Name -HiddenFromAddressListsEnabled $true #-DeliverToMailboxAndForward $False -ForwardingAddress $Man
        }
        #Disabled, move on to next account
        Else {
            Write-Output "$UserID is already disabled"
        }
    }
    #If doesn't exist in AD, display output
    Else {
        Write-Output "User does not exist"
    }
    $i ++
}