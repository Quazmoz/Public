#Run this to get a list of folders/files and output them to excel
#This is very basic but can give a good overview for whoever is trying to look through folder structure/items
Get-ChildItem -Recurse -Directory |
    Select-Object FullName |
    Export-Csv Test.csv -NoTypeInformation