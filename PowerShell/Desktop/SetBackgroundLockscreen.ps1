<#
.SYNOPSIS
    Set background or lockscreen image on Windows Client that can't be changed by users.
.DESCRIPTION
    Script to set a desired image as a Desktop Background and / or Lockscreen Background on a computer. Use a direct link to your image for either $Background, $Lockscreen or both. Uses PersonalisationCSP.
.NOTES
    Version:    1.0
    Created:    2025/10/10
    Author:     Chris Higham
#>

# Variables
$Background = $null # Set to $null if not needed
$Lockscreen = $null # Set to $null if not needed
$PCSPPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$LogPath = "$env:ProgramData\WorkScripts\SetBackGroundLockscreen\$((Get-Date -F 'yyyyMMdd'))"
$Images = "$LogPath\Resources"

If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $LogPath *> $null;}
Start-Transcript -path $LogPath\log.txt
Write-Host "Checking if running as Administrator..."
If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Script must be ran as Administrator."
    Exit
}
Write-Host "Confirmed Administrator!";""

If(!(Test-Path -Path $PCSPPath)){New-Item $PCSPPath -Force}
If(!(Test-Path -Path $Images)){New-Item -ItemType "Directory" -Path $Images *> $null}

If ($null -ne $Background) {
    Write-Host "Downloading Desktop Background image..."
    $BGImage = "$Images\BG.jpg"
    Try{Start-BitsTransfer -Source $Background -Destination "$BGImage"}
    Catch{Write-Host "Unable to download image...";"$($_.Exception.Message)"}
    Write-Host "Setting Desktop Background..."
    New-ItemProperty -Path $PCSPPath -Name DesktopImageUrl -Value $BGImage -PropertyType String -Force
    New-ItemProperty -Path $PCSPPath -Name DesktopImagePath -Value $BGImage -PropertyType String -Force
    New-ItemProperty -Path $PCSPPath -Name DesktopImageStatus -Value 1 -PropertyType DWORD -Force
    Write-Host "Successfully set Desktop Background!"
}

If ($null -ne $Lockscreen) {
    Write-Host "Downloading Lockscreen image..."
    $LSImage = "$Images\LS.jpg"
    Try{Start-BitsTransfer -Source $Lockscreen -Destination "$LSImage"}
    Catch{Write-Host "Unable to download image...";"$($_.Exception.Message)"}
    Write-Host "Setting Lockscreen image..."
    New-ItemProperty -Path $PCSPPath -Name LockScreenImageUrl -Value $LSImage -PropertyType String -Force
    New-ItemProperty -Path $PCSPPath -Name LockScreenImagePath -Value $LSImage -PropertyType String -Force
    New-ItemProperty -Path $PCSPPath -Name LockScreenImageStatus -Value 1 -PropertyType DWORD -Force
    Write-Host "Successfully set Lockscreen image!"
}

Stop-Transcript