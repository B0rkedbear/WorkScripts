<#
    MirrorFileShare v1.0
    
    Author: Chris Higham
    Date: 06/10/2025

    Simple script to mirror multiple file shares to a new server to assist with Server / Domain migrations. 
    
    Script will accept UNC or Local paths for either $SourceFolder or $DestinationLocation variables.
#>

$LogPath = "$env:ProgramData\WorkScripts\MirrorShare\$((Get-Date -F 'yyyyMMdd-HHmm'))"
$SourceServer = "\\Server"
$SourceFolders = "Docs", "Finance", "Tools"
$DestinationLocation = "C:\SharedFolders"
If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $LogPath *> $null}
Start-Transcript -Path $LogPath\ScriptLog.txt

ForEach ($Folder in $SourceFolders) {
    $Source = "$SourceServer\$Folder"
    $Destination = "$DestinationLocation\$Folder"
    If(!(Test-Path -path $("filesystem::$Source"))) {
        If(!(Test-Path -Path $Destination)){
            Write-Host "$Destination doesn't exist. Creating now..."
            New-Item -ItemType "Directory" -Path $Destination
        }
        Write-Host "Mirroring data from $Source to $Destination"
        robocopy $Source $Destination /MIR /COPYALL /DCOPY:T /B /E /EFSRAW /V /R:4 /W:10 /LOG:$LogPath\$Folder.log
    }
}
Stop-Transcript