$EndTime = (Get-Date).AddMinutes(30) # Set timer in minutes
Write-output "Preventing sleep until $EndTime"
While ($EndTime -gt (Get-Date)) {
  (New-Object -com "Wscript.Shell").SendKeys("+{F14}")
  Write-Output "$(Get-Date -Format "HH:mm:ss")"
  Start-Sleep -Seconds 59
}