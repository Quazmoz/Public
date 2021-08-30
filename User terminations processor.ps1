#***This must be run with outlook closed***
#This script can be modified to filter emails and write their contents to a .txt file
#This script is in two sections
#Parameters
#This is the email account you are trying to search within
$Account = "quinn.favo@contoso.com"
#This is the email folder to search
$Folder = "Inbox"
#Variable used to search the body of emails, enter as a string whatever phrase of text you are looking for, the asterisks should be present at the beginning and end of the string
$BodySearch = "*Account Termination Request*"
#Counter for how many emails were received that match the above parameters, this will be printed at the end of the script to verify success and how many emails were committed to the .txt file
$EmailCheck = 0

#This assigns the path of your current desktop to a variable to be used later
$DesktopPath = [Environment]::GetFolderPath("Desktop")

#Create outlook COM object to search folders
$Outlook = New-Object -ComObject Outlook.Application
$OutlookNS = $Outlook.GetNamespace("MAPI")

#Get all emails from specific account and folder
$AllEmails = $OutlookNS.Folders.Item($Account).Folders.Item($Folder).Items
#Filter emails based on the previously specified string in #Bodysearch
$ReportsEmails = $AllEmails | Where-Object { ($_.HTMLBody -like $BodySearch)}

#Count number of emails that contain the string specified in #Bodysearch
$ReportsEmails | ForEach-Object {$EmailCheck = $EmailCheck + 1}

#Display number of emails found
Write-Output $EmailCheck
#Write the contents of the body from each email to a txt on the desktop
$ReportsEmails.Body | Out-File $DesktopPath\emails.txt

#Quit Outlook COM Object
$Outlook.Quit()

#Kill Outlook after finishing script(allows you to open outlook again)
Stop-Process -Name "OUTLOOK" -Force

#Run the below in the second step
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#Exchange CLI
#Save the emails.txt file to the exchange desktop
#Run the below on exchange server with AD module installed

#Grab desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

$EnableUsers = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("UserID:") }
Write-Output $EnableUsers
$Manager = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("@contoso.COM") }
Write-Output $Manager
$Ticket = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("19") }
Write-Output $Ticket

$Date = Get-Date
$i = 0

#Iterate through users pulled from ticket notification emails
#This will get the name of the user in each email and assign it to the variable $TermUsers
$TermUsers = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("UserID:") }
Write-Output $TermUsers
#This will get the name of the user's manager and assign it to the $Manager variable
$Manager = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("@contoso.COM") }
Write-Output $Manager
#This will get the ticket# starting with 19(or whatever number you specify) and assign it to $Ticket
$Ticket = Get-Content $DesktopPath\emails.txt | Where-Object { $_.Contains("19") }
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
            #-DeliverToMailboxAndForward is set to $False because setting it to true will cause delivery to the forwarding mailbox as well as the original mailbox
            Set-Mailbox -Identity $Var.Name -HiddenFromAddressListsEnabled $true -DeliverToMailboxAndForward $False -ForwardingAddress $Man
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