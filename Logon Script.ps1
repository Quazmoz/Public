#Logon Script for Contoso
#Created by Quinn Favo on 11/6/19

#This is slow and will be optimized gradually

$ErrorActionPreference= 'silentlycontinue'

#Disable WSUS temporarily and install AD PSmodule
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
Restart-Service wuauserv
Get-WindowsCapability -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -Online | Add-WindowsCapability –Online
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU
Restart-Service wuauserv

#Elevate to admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
#Add AD query functionality
Add-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
#Install-WindowsFeature RSAT-AD-PowerShell
Import-Module ActiveDirectory

#Pull AD info
$US = Get-ADComputer -Filter 'Name -like "US*fs*"'
$CA = Get-ADComputer -Filter 'Name -like "CA*fs*"'
$FSs = $US += $CA
#Get AD object for the user
$groups = Get-ADPrincipalGroupMembership $env:username | Select-Object name

#Drive Letter count
$i = 0

#Drive letter array
#Omitted: A, B, C, D, E, F, P - use these drives(except C and P) for manual mapping
$letters = @('G','H','I','J','K','L','M','N','O','Q','R','S','T','U','V','W','X','Y','Z')

#Filter variables
$filtervar = "CNA-*"
$admin = "Administration"
$engineering = "Engineering"
$environmental = "Environmental"
$executive = "Executive"
$fi = "FI"
$hr = "HR"
$it = "IT"
$lanusers = "LanUsers"
$le = "LE"
$legal = "Legal"
$lossprevention = "LossPrevention"
$mm = "MM"
$operations = "Operations"
$payroll = "Payroll"
$pm = "PM"
$pp = "PP"
$qm = "QM"
$scale = "Scale"
$sd = "SD"
$semco = "Nam-Semco*"

#Mapped drives
$drives = Get-PSDrive

#Wipe previous mappings
Write-Output "This script will remove previously auto-mapped drives and add all drives that you have permission to access but will not affect your C or P drive"
Write-Output "Drives added manually using Drive letters A, B, D, E, F, will not be affected so you may use these letters to map extra drives that you may need"

Foreach ($letter in $letters) {
    Foreach ($drive in $drives.name) {
        If ("$drive" -like "$letter") {
            $drive = $drive += ":"
            net use $drive /delete
            #Remove-PSDrive -Name $drive -Force <-- this does not work
        }
    }
}

#Add all mapped drives based on AD user account group membership
Foreach ($group in $groups) {

    #Special Groups
    If ($group -match $semco) {
                
        New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\CAMLFS001\Semco-Stanco" -Persist
        $i++
        
    }

    #Filter based on CNA-
    If ($group -match $filtervar) {
        #Make variable that contains site code
        $output = $group.name.split('-')
        If ($output[1].length -gt 2) {
            $output[1] = $output[1].remove(0, 2)
            Write-Output $output[1]
        }
        #drive mappings per group (Regular CNA-)
        If ($group -match $admin) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$admin" -Persist
                    $i++
                }
            }
        }
        If ($group -match $engineering) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$engineering" -Persist
                    $i++
                }
            }
        }
        If ($group -match $environmental) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$environmental" -Persist
                    $i++
                }
            }
        }
        If ($group -match $executive) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$executive" -Persist
                    $i++
                }
            }
        }
        If ($group -match $fi -and $group -notmatch 'confidential' -or $group -match "FI-Confidential") {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$fi" -Persist
                    $i++
                }
            }
        }
        If ($group -match $hr) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$hr" -Persist
                    $i++
                }
            }
        }
        If ($group -match $it) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$it" -Persist
                    $i++
                }
            }
        }
        If ($group -match $lanusers) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\SharedData" -Persist
                    $i++
                }
            }
        } 
        If ($group -match $le) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$le" -Persist
                    $i++
                }
            }
        }
        If ($group -match $legal) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$legal" -Persist
                    $i++
                }
            }
        }
        If ($group -match $lossprevention) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$lossprevention" -Persist
                    $i++
                }
            }
        }
        If ($group -match $mm) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$mm" -Persist
                    $i++
                }
            }
        }
        If ($group -match $operations) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$operations" -Persist
                    $i++
                }
            }
        }
        If ($group -match $payroll) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$payroll" -Persist
                    $i++
                }
            }
        }
        If ($group -match $pm) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$pm" -Persist
                    $i++
                }
            }
        }
        If ($group -match $pp) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$pp" -Persist
                    $i++
                }
            }
        }
        If ($group -match $qm) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$qm" -Persist
                    $i++
                }
            }
        }
        If ($group -match $scale) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$scale" -Persist
                    $i++
                }
            }
        }
        If ($group -match $sd) {
            Foreach ($FS in $FSs.name) {
                If ($FS -match $output[1]) {
                    New-PSDrive -Name $letters[$i] -PSProvider "FileSystem" -Root "\\$FS\$sd" -Persist
                    $i++
                }
            }
        }
        #Fix Anvil/Northern Lime discrepancy(works for users that do not have both Anville groups AND CANL groups)
        If ($output[1] -match "AN" -and $groups -notcontains "CNA-NL*") {
            
            $baddrives = Get-CimInstance -Class Win32_NetworkConnection
            $baddrives | Where-Object -FilterScript {$_.RemoteName -match "CANLFS*"}
            Foreach ($rm in $baddrives.LocalName){
                net use $rm /delete
                Write-Output "Deleted $rm drive because it was accidentally added"
            }
        }
    }
}

