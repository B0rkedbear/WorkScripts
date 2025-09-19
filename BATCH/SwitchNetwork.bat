::    Switch Network v1.0
::    
::    Author: Chris Higham
::    Date: 12/07/2025
::  
::    Script originally written for a client who needed to reguarly change between 2 networks - one being an airgapped network with no DHCP. Script was written in Batch instead of Powershell to avoid having to change execution policies.  
::    
::    For the 'interface' variable use the command below to identify device name required;
::   netsh interface ipv4 show config


:: Define network settings
@echo off
set interface=WiFi
set staticIP=10.0.0.10
set subnetMask=255.255.255.0
set defaultGateway=10.0.0.1
set primaryDNS=10.0.0.2
set secondaryDNS=1.1.1.1

:: Check if required interface IP is DHCP or is Static.
setlocal EnableDelayedExpansion
netsh interface ipv4 show config "%interface%"
FOR /F "tokens=3" %%i IN ('netsh interface ipv4 show config "%interface%" ^| findstr /C:"DHCP enabled"') DO set dhcpStatus=%%i
echo DHCP Enabled: %dhcpStatus%

if "%dhcpStatus%"=="Yes" (
    echo Changing IP address to static.
    netsh interface ipv4 set address "%interface%" static %staticIP% %subnetMask% %defaultGateway% >nul
    netsh interface ipv4 set dnsservers "%interface%" static %primaryDNS% primary >nul
    netsh interface ipv4 add dns "%interface%" %secondaryDNS% >nul
    echo Static IP configuration applied.
    netsh interface ipv4 show config "%interface%"
) else if "%dhcpStatus%"=="No" (
    echo Switching back to DHCP
    netsh interface ipv4 set address "%interface%" dhcp >nul
    netsh interface ipv4 set dnsserver "%interface%" dhcp >nul
    echo DHCP configuration applied
    netsh interface ipv4 show config "%interface%"
) else (
    echo %interface% not found.
    echo Run 'netsh interface ipv4 show config' to ensure 'interface' variable is correct.
    pause
    exit /b 0
)

echo Configuration complete.
pause
