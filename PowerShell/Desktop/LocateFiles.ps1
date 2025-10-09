<#
    Script: LocateFiles v1.0
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

    Updates;
    v1.1 - Updated code to find files that match search parameters in order
    
#>

$Path = "C:\Company Data\Shares"
$Extensions = "*.doc","*.xls","*.ppt"
$TotalFiles = 0
$LogPath = "$env:ProgramData\WorkScripts\LocateFiles"
If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $LogPath *> $null}

# Make files report root first 
$queue = New-Object System.Collections.Generic.Queue[System.IO.DirectoryInfo]
$queue.Enqueue((Get-Item $path))
$results = @()
while ($queue.Count -gt 0) {
    $currentDir = $queue.Dequeue()
    # Find matching files in current directory
    foreach ($ext in $extensions) {
        Get-ChildItem -Path $currentDir.FullName -Filter $ext -File -ErrorAction SilentlyContinue | ForEach-Object {
            $results += [PSCustomObject]@{
                FilePath      = $_.DirectoryName
                FileName      = $_.BaseName
                FileExtension = $_.Extension
            }
            Write-Host -ForegroundColor Green "$($_.FullName)"
            $TotalFiles++
        }
    }
    # Queue subdirectories
    Get-ChildItem -Path $currentDir.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $queue.Enqueue($_)
    }
}

# Export to CSV
$results | Export-Csv -Path "$LogPath\FileReport.csv" -NoTypeInformation

Write-Host "";"Found $TotalFiles files with the requested formats"
Write-Host "Creatd report: $LogPath\FileReport.csv"