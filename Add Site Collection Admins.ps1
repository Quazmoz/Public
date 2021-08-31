
Connect-SPOService -Url https://contoso-admin.sharepoint.com
#use above if below doesnt work to connect
#Variables for processing
$AdminURL = "https://contoso-admin.sharepoint.com/"
$AdminName = "user@contoso.onmicrosoft.com"

#User Names Password to connect 
$Password = Read-host -assecurestring "Password?"
$Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName, $Password

#Connect to SharePoint Online
Connect-SPOService -url $AdminURL -credential $Credential
 
$Sites = Get-SPOSite -Limit ALL
 
Foreach ($Site in $Sites)
{
    Write-host "Adding Site Collection Admin for:"$Site.URL
    Set-SPOUser -site $Site -LoginName "user" -IsSiteCollectionAdmin $True
}

#single user
Set-SPOUser -site "https://contoso-my.sharepoint.com/personal/user_contoso_net" -LoginName "user" -IsSiteCollectionAdmin $true
#get all sites
$sites = Get-SPOSite -IncludePersonalSite $true -Limit All

#loop through sites and set admin
foreach ($site in $sites) {
    Set-SPOUser -site $site.url -LoginName "user" -IsSiteCollectionAdmin $true
    $SiteAdmins = Get-SPOUser -Site $site.url -Limit ALL | Where { $_.IsSiteAdmin -eq $True}
}

#test
get-spouser -site "https://contoso-my.sharepoint.com/personal/user_contoso_net" -Limit ALL | Where { $_.IsSiteAdmin -eq $True}
$users = @();
foreach ($site in $sites)
{

$AllUsers = Get-SPOUser -Site $site.Url -Limit all | select DisplayName, LoginName,IsSiteAdmin
Write-Output $AllUsers
$users+=$AllUsers
$AllUsers = $null
#Write-Host $AllSite.Url" completed"

}
#add admin to site
Set-SPOUser -site "https://contoso-my.sharepoint.com/personal/user_contoso_net" -LoginName "azfavo" -IsSiteCollectionAdmin $true

$SiteAdmins = Get-SPOUser -Site "https://contoso-my.sharepoint.com/personal/user_contoso_net" -Limit ALL | Where { $_.IsSiteAdmin -eq $True}
$SiteAdmins = Get-SPOUser -Site "https://contoso-my.sharepoint.com/personal/user_contoso_net" -Limit ALL
#test
$SiteCollURL="https://contoso-my.sharepoint.com/personal/user/"
Get-SPOUser -Site "https://contoso-my.sharepoint.com/personal/user" -Limit all | select *
Get-SPOSite -Filter { Url -like "https://contoso-my.sharepoint.com/personal/user" }
#Get the Site colection
$SiteColl = Get-SPOSite -URL $SiteCollURL
     
#Get all Site Collection Administrators
$SiteAdmins = Get-SPOUser -Site $SiteCollURL -Limit ALL | Where { $_.IsSiteAdmin -eq $True}
foreach($Admin in $SiteAdmins)
{
    Write-host $Admin.LoginName     
}