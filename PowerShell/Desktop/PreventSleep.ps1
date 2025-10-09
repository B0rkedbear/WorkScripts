Write-output "Preventing sleep..."
while ($true) {
  $WScript = New-Object -com "Wscript.Shell"
  $WScript.SendKeys("+{F14}")
  Write-Output "$(Get-Date -Format "HH:mm:ss")"
  Start-Sleep -Seconds 59
}