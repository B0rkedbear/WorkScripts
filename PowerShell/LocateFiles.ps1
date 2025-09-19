<#
    LocateFiles v1.0

    Author: Chris Higham
    Date: 03/07/2025

    Script locate files within directories specified in $Path. Originally wrote to assist with locating documents created
    in older versions of MS Office before performing Sharepoint Migrations.

    To use this script replace the formats assigned to $Formats as required.
    Example 1: Locate Office97 or earlier formats with the below;
    $Formats = "*.doc","*.xls","*.ppt"
    Example 2: Locate OpenOffice documents with the below;
    $Formats = "*.odt","*.ods","*.odp","*.odg","*.odf" 

    Can also be used to locate files if you can remember part of the name but not the location.
    Example: Locate Outlook's NK2 caches on your computer with the below; 
    $Formats = "Stream_Autocomplete_*" 

    Uses "Start-Transcript" cmdlet to log output whilst searching to help identify if the account running the script
    doesn't have access to any subfolders being scanned.
#>

$Path = "C:\Company Data\Shares"
$Formats = "*.doc","*.xls","*.ppt"
$TotalFiles = 0
$LogPath = "$env:ProgramData\WorkScripts\LocateFiles\$((Get-Date -F 'yyyyMMdd-HHmmss'))"
$CSV = "$LogPath\FileReport.CSV"
If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $LogPath *> $null}
Start-Transcript -path $LogPath\TerminalLog.txt
    Write-Host ""
    Write-Host "Searching for files with the extensions $Formats within $Path in it's subfolders"
    Write-Host ""
    ### Creates CSV for report then finds relevant files and their full path
    Get-ChildItem -Path $Path -Recurse -Include @($Formats) | ForEach-Object {
        [PSCustomObject]@{
            FilePath = $_.DirectoryName
            FileName = $_.BaseName
            FileExtension = $_.Extension
            FileSize = $_.Length
        }
        Write-Host -ForegroundColor Green "$($_.FullName)"
        $TotalFiles++
    } | Export-CSV -Path $CSV -NoTypeInformation
    
    Write-Host ""
    Write-Host "Found $TotalFiles files with the requested formats"
    Write-Host "Results are saved as FileReport.csv in $LogPath"
Stop-Transcript