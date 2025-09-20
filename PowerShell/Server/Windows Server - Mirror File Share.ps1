<#
    MirrorFileShare v1.0
    
    Author: Chris Higham
    Date: 15/09/2025

    Simple script to mirror a file share to a new server to assist with Server / Domain migrations. 
    
    Script will accept UNC or Local paths for either $SourceFolder or $MirrorFolder variables.
#>

$LogPath = "$env:ProgramData\WorkScripts\MirrorFileShare\$((Get-Date -F 'yyyyMMdd-HHmmss'))"
$SourceFolder = "\\Server\Share"
$MirrorFolder = "C:\SharedFolders\Docs"
If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $Path *> $null}

robocopy $SourceFolder $MirrorFolder /MIR /COPYALL /DCOPY:T /B /E /EFSRAW /V /R:4 /W:10 /LOG:$LogPath\ShareLog.log