<#
    ActivateServer v1.0
    
    Author: Chris Higham
    Date: 11/09/2025

    Script to automatically convert Evaluation versions of Windows Server to Retail and activate if a valid key is provided.
    This script will provide the user with a menu with available versions to convert your image to. May work with upgrading
    Windows clients to higher license (ie// Windows 11 Home to Windows 11 Pro) but this functionality is untested.
    
    List of Microsofts Generic Keys incase your retail license hasn't arrived;
    WindowsServer2025Standard       =   "TVRH6-WHNXV-R9WG3-9XRFY-MY832"
    WindowsServer2025Datacenter     =   "D764K-2NDRG-47T6Q-P8T8W-YP6DF"
    WindowsServer2022Standard	    =   "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
    WindowsServer2022Datacenter	    =   "WX4NM-KYWYW-QJJR4-XV3QB-6VM33"
    WindowsServer2019Standard	    =   "N69G4-B89J2-4G8F4-WWYCC-J464C"
    WindowsServer2019Datacenter	    =   "WMDGN-G9PQG-XVVXX-R3X43-63DFG"
    WindowsServer2019Essentials	    =   "WVDHN-86M7X-466P6-VHXV7-YY726"
    WindowsServer2016Standard	    =   "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
    WindowsServer2016Datacenter	    =   "CB7KF-BWN84-R7R2Y-793K2-8XDDG"
    WindowsServer2016Essentials	    =   "JCKRF-N37P4-C2D82-9YXRT-4M63B"
    WindowsServer2012R2Standard	    =   "D2N9P-3P6X9-2R39C-7RTCD-MDVJX"
    WindowsServer2012R2Datacenter	=   "W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
#>

$License = "TVRH6-WHNXV-R9WG3-9XRFY-MY832"
$LogPath = "$env:ProgramData\WorkScripts\ActivateServer\$((Get-Date -F 'yyyyMMdd-HHmmss'))"
$AvailableEditions = (Get-WindowsEdition -Online -Target).Edition
$CurrentEdition = (Get-WindowsEdition -Online).Edition

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "ERROR: Script must be ran as Administrator to install Windows Server license."
    Write-Host "Press any key to quit...";
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Exit
} Else {
    If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $LogPath *> $null}
    Try {
        $DISMModule = Get-Module -ListAvailable "DISM"
        If(!($DISMModule)) {
            Write-Output "DISM module missing. Attempting to install."
    		Install-Module DISM -Force -Confirm:$False
            Import-Module DISM -DisableNameChecking
        } Else {
            Write-Output "Importing DISM module."
            Import-Module DISM -DisableNameChecking
        }
    } Catch {
        Write-Output "Error: $($_.Exception.Message)" 
        Exit
    }
}
Start-Transcript -path $LogPath\log.txt

For ($i = 0; $i -lt $AvailableEditions.Count; $i++) {
    Write-Host "[$($i + 1)] $($AvailableEditions[$i])"
}
$Choice = Read-Host "Please select an option (Enter the number)"
If($Choice -match '^\d+$' -and [int]$Choice -ge 1 -and [int]$Choice -le $AvailableEditions.Count) {
    $TargetEdition = $AvailableEditions[$Choice - 1]
    Write-Host "You selected: $TargetEdition"
} Else {
    Write-Host "Invalid choice. Please enter a valid number."
}
If($CurrentEdition -match ".*Eval$") {
    DISM /online /Set-Edition:$TargetEdition /GetEula:$LogPath\EULA.rtf
    DISM /online /Set-Edition:$TargetEdition /ProductKey:$License /AcceptEula
} Else {
    Write-Output "You are not on an Evaluation version of Windows Server."
}
Get-Module -ListAvailable "DISM" | Remove-Module
Write-Output "Please restart the server to complete licensing."
Do {
	$YesNo = Read-Host "Restart now? (Yes/No)"
	$YesNo = $YesNo.ToLower()
	Switch ($YesNo){
		{$_ -in @("y","yes")} {Write-Output "Server will reboot in 10 seconds"; Start-Sleep -Seconds 10; shutdown /r /t 0}
		{$_ -in @("n","no")} {Exit}
		Default {Write-Output "Invalid input. Please enter 'Yes' or 'No'."}
	}
} While ($true)

Stop-Transcript