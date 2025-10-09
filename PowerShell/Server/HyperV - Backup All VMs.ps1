<#
.SYNOPSIS
    Backup Hyper-V Virtual Machines
.DESCRIPTION
    Script to be used with Task Scheduler to automatically backup all VMs to a location specified in $BackupRoot. Will then check if any backups are more than 1 week old and automatically prune them. 
    Currently requires variables below to be set manually.
.NOTES
    Version:    1.0
    Created:    2025/10/07
    Author:     Chris Higham
#>

# Variables
$BackupRoot = "C:\HyperVBackup"
$BackupDate = Get-Date -F 'yyyy-MM-dd'
$BackupFolder = "$BackupRoot\$BackupDate" 
$LogFile = "$BackupFolder\Log.txt" 

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "ERROR: Script must be ran as Administrator to install Windows Server license."
    Exit
}
If(!(Test-Path -Path $BackupFolder)){New-Item -Path $BackupFolder -ItemType "Directory" *>$null}
Start-Transcript -path $LogFile

$VMs = Get-VM
ForEach ($VM in $VMs) {
    Try {
        $VMFolder = "$BackupFolder\$($VM.Name)"
        Write-Host "$($VM.Name): Backing up..."
        New-Item -Path $VMFolder -ItemType "Directory" *>$null
        Export-VM -Name $($VM.Name) -Path $VMFolder
        Write-Host "$($VM.Name): Completed backup!"
    } Catch {
        Write-Host "$($VM.Name): Error";"$($_.Exception.Message)"
    }
}
Write-Host "Completed backups!";""

Write-Host "Looking for backups older than 7 days..."
$Backups = Get-ChildItem -Path $BackupRoot
$TotalCleared = $0
ForEach ($Backup in $Backups){
    If ($Backup.CreationTime -lt (Get-Date).AddDays(-7)) {
        Write-Host "Deleting backup: $Backup"
        Try {
            Remove-Item $Backup -Recurse
            Write-Host "Deleted backups from: $Backup"
            $TotalCleared++
        } Catch {
            Write-Host "Error: $($_.Exception.Message)"
        }
    }
}
If ($TotalCleared -gt 0) {
    Write-Host "Backups deleted: $TotalCleared."
} Else {
    Write-Host "No backups to delete."
}

# End backup log
Stop-Transcript