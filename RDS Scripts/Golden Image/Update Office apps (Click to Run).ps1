$click2run = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"

function Get-InstalledOfficeVersion {
    (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration").VersionToReport
}

if (Test-Path $click2run){
    Write-Host "Updating Office apps..."
    $versionNow = Get-InstalledOfficeVersion
    Write-Host "Current Office version is $versionNow"
    Start-Process -FilePath $click2run -ArgumentList "/update user" -Wait -NoNewWindow
    Write-Host "Updated Office apps."
    $versionNow = Get-InstalledOfficeVersion
    Write-Host "Current Office version is $versionNow"
}
else{
    Write-Host "Couldn't find the click to run updater (OfficeC2RClient.exe)"
}
