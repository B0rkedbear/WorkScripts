<#
    Exchange Online - Blocked Senders v1.0
    
    Author: Chris Higham
    Date: 12/08/2025

    Script that gets the blocked senders for all mailboxes in Exchange Online and saves them into a CSV file in the users "Documents" folder.
    The location the CSV is saved to can be changed by editing the $Path variable at the start of the script. Mailboxes with no addresses 
    blocked won't be shown.

    Try statement at start of script checks if ExchangeOnlineManagement module is installed before attempting to import. If it's not it then
    checks if it's being ran in an elevated terminal before either installing or requesting the user to try again as Administrator.
    
    Note: For an account to connect to a tennant using the ExchangeOnlineManagement module it must be a Global Administrator or Global Reader
    on Entra, or a member of the Compliance Management, Delegated Setup, Hygiene Management, Organization Management or View-Only Organization
    Management role groups.
#>
  
$GlobalAdmin = "user@domain.com"
$Path = [Environment]::GetFolderPath("MyDocuments")
$CSV = "$Path\UserBlocklist.csv"

Try {
    If(!(Get-Module -ListAvailable "ExchangeOnlineManagement")) {
        Write-Host -ForegroundColor Green "ExchangeOnlineManagement module missing. Attempting to install."
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Host -ForegroundColor Red "ERROR: Script must be ran as Administrator to install modules."
            Write-Host "Press any key to quit...";
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            Exit
        }
        Install-Module ExchangeOnlineManagement -Force -Confirm:$False
        Write-Host -ForegroundColor Green "ExchangeOnlineManagement install successful!";"Importing ExchangeOnlineManagement module."
        Import-Module ExchangeOnlineManagement -DisableNameChecking
    } Else {
        Write-Host -ForegroundColor Green "Importing ExchangeOnlineManagement module."
        Import-Module ExchangeOnlineManagement -DisableNameChecking
    }
} Catch {
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
If(!(Test-Path -Path $Path)){New-Item -ItemType "Directory" -Path $Path *> $null}
  
Write-Host -ForegroundColor Green "Connecting to ExchangeOnline..."
Connect-ExchangeOnline -UserPrincipalName $GlobalAdmin
Write-Host -ForegroundColor Green "Checking user blocklists..."

Get-EXOMailbox -ResultSize Unlimited | ForEach-Object {
    $Blocklist = Get-MailboxJunkEmailConfiguration -Identity $_.PrimarySMTPAddress
    If ($Blocklist.BlockedSendersAndDomains) {
        [PSCustomObject]@{
            Name = $_.DisplayName
            Email = $_.PrimarySMTPAddress
            Blocklist = $Blocklist.BlockedSendersAndDomains
        }
    }
} | Export-CSV -Path $CSV -NoTypeInformation -Force

Write-Host -ForegroundColor Green "Complete! Report has been saved in $CSV"
Disconnect-ExchangeOnline -Confirm:$false