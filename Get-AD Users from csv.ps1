$Users = Get-Content 'C:\Users\favo\Desktop\hold.csv'

foreach ($User in $Users)
{
    #$User = Remove-StringDiacritic $User
    Write-Output $User
    #$checked = Get-ADUser -Filter {Surname -like "$User*"} #-ResultSetSize:$null -ResultPageSize:1000 | Format-Table Name, SamAccountName
    Get-ADUser -filter {mail -like $User} -Properties * | Select sAMAccountName, extensionAttribute10, extensionAttribute11 | export-csv -append c:\temp\extensionattribute.csv 

}

#get shared accounts
Get-ADUser -filter * -Properties * | Select sAMAccountName, extensionAttribute10, description, office |Where-Object {$_.extensionAttribute10 -eq 4} | export-csv -append c:\temp\sharedAccounts.csv 

#test
Get-ADUser -filter {mail -like $user} -Properties * 

function Remove-StringDiacritic {
    <#
.SYNOPSIS
    This function will remove the diacritics (accents) characters from a string.
.DESCRIPTION
    This function will remove the diacritics (accents) characters from a string.
.PARAMETER String
    Specifies the String(s) on which the diacritics need to be removed
.PARAMETER NormalizationForm
    Specifies the normalization form to use
    https://msdn.microsoft.com/en-us/library/system.text.normalizationform(v=vs.110).aspx
.EXAMPLE
    PS C:\> Remove-StringDiacritic "L'été de Raphaël"
    L'ete de Raphael
.NOTES
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
    github.com/lazywinadmin
#>
    [CMdletBinding()]
    PARAM
    (
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String[]]$String,
        [System.Text.NormalizationForm]$NormalizationForm = "FormD"
    )

    FOREACH ($StringValue in $String) {
        Write-Verbose -Message "$StringValue"
        try {
            # Normalize the String
            $Normalized = $StringValue.Normalize($NormalizationForm)
            $NewString = New-Object -TypeName System.Text.StringBuilder

            # Convert the String to CharArray
            $normalized.ToCharArray() |
                ForEach-Object -Process {
                    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                        [void]$NewString.Append($psitem)
                    }
                }

            #Combine the new string chars
            Write-Output $($NewString -as [string])
        }
        Catch {
            Write-Error -Message $Error[0].Exception.Message
        }
    }
}