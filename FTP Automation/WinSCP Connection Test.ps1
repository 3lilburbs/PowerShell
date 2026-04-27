# Simple FTP Connection Test

# CHANGE THESE:
$sessionUrl = "ftpes://ftpuser:password;fingerprint=00-00-00-...@ftp-server.co.uk"
$WinSCPDLL = "C:\WinSCP\WinSCPnet.dll"

# TEST:
try {
    Add-Type -Path $WinSCPDLL
    $sessionOptions = New-Object WinSCP.SessionOptions
    $sessionOptions.ParseUrl($sessionUrl)
    $session = New-Object WinSCP.Session
    
    Write-Host "Connecting..."
    $session.Open($sessionOptions)
    Write-Host "SUCCESS! Connected to server." -ForegroundColor Green
    
    $session.Dispose()
}
catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}
