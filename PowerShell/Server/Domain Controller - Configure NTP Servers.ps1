<#
    Domain Controller - Configure NTP Service v1.0
    
    Author: Chris Higham
    Date: 06/10/2025

    Configures uk.pool.ntp.org, time.windows.com and time.cloudflare.com as the time sources on Windows Server, then enables the NTP Server role for domain client use.
#>

### Variables
$LogPath = "$env:ProgramData\WorkScripts\ConfigureNTP\"
$RegExportKey = "HKLM\SYSTEM\CurrentControlSet\Services\W32Time"
$RegExportPath = "$LogPath\W32TimeKeyOriginal.reg"
$W32Time = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time"
$NTPSyncValue = (Get-ItemProperty -Path "$W32Time\TimeProviders\NtpClient").SpecialPollInterval

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "ERROR: Script must be ran as Administrator to install Windows Server license."
    Write-Host "Press any key to quit...";
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Exit
}
If(!(Test-Path -Path $LogPath)){New-Item -ItemType "Directory" -Path $LogPath *> $null}
Start-Transcript -Path $LogPath\SriptLog.txt

### Backs up HKLM:\SYSTEM\CurrentControlSet\Services\W32Time and it's keys before making changes
reg export $RegExportKey $RegExportPath *> $null
Write-Output "";"Registry key exported to $RegExportPath";""
w32tm /query /configuration > "$LogPath\W32TM Config Old.txt"
Write-Output "W32TM Config backup created.";"Saved to $LogPath\W32TM Config Old.txt";""

### Settings for Domain Controller
$Win32BB = Get-CimInstance -ClassName Win32_BaseBoard
If (($Win32BB).Manufacturer -eq "Microsoft Corporation" -And ($Win32BB).Product -eq "Virtual Machine"){
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider" -Name "Enabled" -Value "0" -Force
}
Stop-Service -Name "w32time"
w32tm /unregister
w32tm /register
Start-Service -Name "w32time"
tzutil /s "GMT Standard Time"
w32tm /config /manualpeerlist:“uk.pool.ntp.org,0x8,time.windows.com,0x8,time.cloudflare.com,0x8” /syncfromflags:manual /reliable:yes /update
w32tm /resync
Stop-Service -Name "w32time"
Start-Service -Name "w32time"

### Check poling interval
Write-Output "The NTP polling rate is $NTPSyncValue seconds on this server."

Stop-Transcript