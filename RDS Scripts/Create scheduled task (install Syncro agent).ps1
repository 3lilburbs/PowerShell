# Run this on the golden image
$scriptPath = "C:\ProgramData\Scripts\Install-Syncro.ps1"
$msiPath = "\\SERVER01\Shared\SyncroInstaller.msi"

# Create the install script
$installScript = @"
`$msiPath = "$msiPath"
`$logPath = "C:\Windows\Temp\syncro-install-`$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Check if Syncro is already installed
`$syncroService = Get-Service -Name "Syncro*" -ErrorAction SilentlyContinue

if (-not `$syncroService) {
    if (Test-Path `$msiPath) {
        Start-Process msiexec.exe -ArgumentList "/i ```"`$msiPath```" /qn /norestart /l*v ```"`$logPath```"" -Wait -NoNewWindow
    }
}
"@

# Create directory and save script
New-Item -Path "C:\ProgramData\Scripts" -ItemType Directory -Force
Set-Content -Path $scriptPath -Value $installScript

# Create scheduled task to run at startup
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $scriptPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "Install-Syncro-RMM" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Auto-install Syncro RMM on boot"
