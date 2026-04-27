# Update-TeamsGoldenImage.ps1
# Purpose: Update Microsoft Teams on a golden image (MSIX/Appx version)

Write-Host "Checking provisioned Teams package..."

# Get the provisioned package for Microsoft Teams (new Teams client)
$teamsPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*MSTeams*" }

if (-not $teamsPackage) {
    Write-Host "Microsoft Teams is not provisioned on this image." -ForegroundColor Red
    exit 1
}

$currentVersion = $teamsPackage.Version
Write-Host "Current Teams version is: $currentVersion"

# Define bootstrapper path
$bootstrapper = "\\BJRDS-FS01\Setup$\Microsoft Teams\Teams New\teamsbootstrapper.exe"

if (-not (Test-Path $bootstrapper)) {
    Write-Host "Teams Bootstrapper teamstootstrapper.exe not found at: $bootstrapper" -ForegroundColor Red
    exit 1
}

Write-Host "Running teamsbootstrapper.exe -p to update Teams..." -ForegroundColor Yellow

# Run the bootstrapper
$updateProcess = Start-Process -FilePath $bootstrapper -ArgumentList "-p" -Wait -PassThru -NoNewWindow

if ($updateProcess.ExitCode -eq 0) {
    # Recheck provisioned Teams package
    $newTeamsPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*MSTeams*" }
    $newVersion = $newTeamsPackage.Version

    if ($newVersion -ne $currentVersion) {
        Write-Host "Teams updated successfully to version: $newVersion" -ForegroundColor Green
    } else {
        Write-Host "Nothing to do - Teams is already the latest version ($currentVersion)."
    }
} else {
    Write-Host "Teams update failed with exit code $($updateProcess.ExitCode)." -ForegroundColor Red
}
