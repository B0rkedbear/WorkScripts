Write-output "Preventing sleep..."
while ($true) {
  (New-Object -com "Wscript.Shell").SendKeys("+{F14}")
  Write-Output "$(Get-Date -Format "HH:mm:ss")"
  Start-Sleep -Seconds 59
}