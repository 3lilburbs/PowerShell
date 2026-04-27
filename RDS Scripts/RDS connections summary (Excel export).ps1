<#
.SYNOPSIS
    This script generates a report on the status of VMs and RDS sessions across specified Hyper-V hosts.

.DESCRIPTION
    The script performs the following tasks:
    - Collects RDS sessions and identifies long and stale sessions.
    - Checks the status of VMs across the specified Hyper-V hosts.
    - Logs long sessions and detects repeat offenders.
    - Exports the collected data to an Excel file.
    - Outputs a summary of the report to the console.

.NOTES
    Author: Michael Waters
    Date: 29/01/2025
    Version: 2.0

.PARAMETER None

.EXAMPLE
    .\Generate-RDS-VM-Report.ps1
#>

# Ensure ImportExcel module is installed
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}

# Paths and timestamps
$reportPath = "C:\Reports"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$excelPath = "$reportPath\RDS_VM_Report_$timestamp.xlsx"
$logFilePath = "$reportPath\LongSessionLog.csv"
# Create the report folder if it doesn't exist
if (-not (Test-Path $reportPath)) { New-Item -ItemType Directory -Path $reportPath }

# Define the Hyper-V Hosts
$HyperVHosts = @(
    "RDS-VH01",
    "RDS-VH02",
    "RDS-VH03"
)

# Init data collections
$vmOffList = @()
$vmInUseList = @()
$vmRunningNoUserList = @()
$longSessionsList = @()
$staleSessionsList = @()

# Collect RDS sessions
$allSessions = Get-RDUserSession
$longSessions = $allSessions | Where-Object { $_.CreateTime -ne $null -and ((Get-Date) - $_.CreateTime).Days -gt 7 }
$staleSessions = $allSessions | Where-Object { $_.DisconnectTime -ne $null -and ((Get-Date) - $_.DisconnectTime).Days -gt 1 }

# Check VMs across Hyper-V hosts
foreach ($hypervHost in $HyperVHosts) {
    try { $vmList = Get-VM -ComputerName $hypervHost }
    catch { continue }

    foreach ($vm in $vmList) {
        $session = $allSessions | Where-Object { $_.ServerName -eq $vm.Name }
        if ($vm.State -eq "Running" -and $session) {
            $vmInUseList += [PSCustomObject]@{ VMName = $vm.Name; HostServer = $hypervHost; UserName = $session.UserName; SessionState = $session.SessionState }
        } elseif ($vm.State -eq "Running" -and -not $session) {
            $vmRunningNoUserList += [PSCustomObject]@{ VMName = $vm.Name; HostServer = $hypervHost; State = $vm.State }
        } elseif ($vm.State -eq "Off") {
            $vmOffList += [PSCustomObject]@{ VMName = $vm.Name; HostServer = $hypervHost; State = $vm.State }
        }
    }
}

# Log long sessions
foreach ($session in $longSessions) {
    $longSessionsList += [PSCustomObject]@{
        UserName = $session.UserName
        HostServer = $session.HostServer
        SessionStart = $session.CreateTime
        DaysActive = ((Get-Date) - $session.CreateTime).Days
    }
}
# Keep track of how long users have been signed in 
$longSessionsList | Export-Csv -Path $logFilePath -NoTypeInformation -Append

# Detect repeat offenders that do not sign out at least once a week
$repeatOffenders = Import-Csv -Path $logFilePath | Group-Object UserName | Where-Object { $_.Count -gt 2 } | ForEach-Object {
    [PSCustomObject]@{
        UserName = $_.Name
        LongSessionCount = $_.Count
        LastLogged = ($_.Group | Sort-Object DateLogged -Descending | Select-Object -First 1).DateLogged
    }
}

# Export data to Excel
# I need a summary tab at the beginnning
$vmInUseList | Export-Excel -Path $excelPath -WorksheetName "VMs In Use" -AutoSize
$vmRunningNoUserList | Export-Excel -Path $excelPath -WorksheetName "Running VMs No User" -AutoSize -Append
$vmOffList | Export-Excel -Path $excelPath -WorksheetName "VMs Off" -AutoSize -Append
$longSessionsList | Export-Excel -Path $excelPath -WorksheetName "Long Sessions" -AutoSize -Append
$staleSessions | Export-Excel -Path $excelPath -WorksheetName "Stale Sessions" -AutoSize -Append
$repeatOffenders | Export-Excel -Path $excelPath -WorksheetName "Repeat Offenders" -AutoSize -Append

# Summary Output
Write-Host "===== Report Summary ====="
Write-Host "Total VMs Off: $($vmOffList.Count)"
Write-Host "Total VMs In Use: $($vmInUseList.Count)"
Write-Host "Running VMs with no user connected: $($vmRunningNoUserList.Count)"
Write-Host "Total Long Sessions (>7 days): $($longSessionsList.Count)"
Write-Host "Total Stale Sessions (>1 day): $($staleSessions.Count)"
Write-Host "Repeat Offenders Detected: $($repeatOffenders.Count)"
Write-Host "Excel report generated at: $excelPath"
Write-Host "Script execution complete."
