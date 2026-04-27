# FTP Import Script

$sessionUrl =  "sftp://ftpuser:password;fingerprint=ssh-ed25519-TVHe23...@ftp-server.co.uk/"
$listPath = "D:\FTP\FTP_Import_History.log" # Keeps a record of files transferred 
$localPath = "D:\Local"
$remotePath = "/Remote"
$sessionLogPath = $Null
$WinSCPDLL = "C:\WinSCP\WinSCPnet.dll"
$archivePath = "$localPath\Original"

## Set your email parameters - called with Send-MailMessage @mailParams
# Sends email unauthenticated via 365 Direct Send
$mailParams = @{
    SmtpServer                = 'example-com.mail.protection.outlook.com'
    Port                      = '25'
    UseSSL                    = $true  
    From                      = 'admin@example.com'
    To                        = 'support@example.com'
    Subject                   = "FTP Import - $(Get-Date -Format g)"
    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
 }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check Original (archive) folder exisits
if (! (Test-Path "$archivePath")){
    Write-Host "Directory does not exist. Creating directory $archivePath"
    New-Item -ItemType Directory -Path $archivePath -Force | Out-Null 
    }

# What files are here now?
$filesNow = Get-ChildItem $localPath -Filter *.csv
if ($null -ne $filesNow){

    Write-Host "Moving csv files in the target directory."
    Move-Item -Path $localPath\*.csv -Destination $localPath\Original
}

try
{
    # Load WinSCP .NET assembly - For this purpose the script file MUST be in the same directory.
    Add-Type -Path $WinSCPDLL
 
    # Setup session options from URL
    $sessionOptions = New-Object WinSCP.SessionOptions
    $sessionOptions.ParseUrl($sessionUrl)
    $session = New-Object WinSCP.Session

    try
    {
        $session.SessionLogPath = $sessionLogPath
        $listPath = [Environment]::ExpandEnvironmentVariables($listPath)
        $listDir = (Split-Path -Parent $listPath) 
        New-Item -ItemType directory -Path $listDir -Force | Out-Null 
        if (Test-Path $listPath)
        {
            Write-Host "Loading list of already downloaded files from $listPath..."
            $downloaded = @(Get-Content $listPath)
        }
        else
        {
            Write-Host "File $listPath with list of already downloaded files doesn't exist yet."
            $downloaded = @()
        }
        Write-Host "Connecting..."
        $session.Open($sessionOptions)
        Write-Host "Looking for new files..."
        $files =
            $session.EnumerateRemoteFiles(
                $remotePath, "*", [WinSCP.EnumerationOptions]::AllDirectories)
        $count = 0
        foreach ($fileInfo in $files)
        {
            $remoteFilePath = $fileInfo.FullName
            if ($downloaded -notcontains $remoteFilePath)
            {
                $remoteFileLen = $fileInfo.Length
                Write-Host `
                    "Found new file $remoteFilePath with size $remoteFileLen, downloading..."
 
                $localFilePath =
                    [WinSCP.RemotePath]::TranslateRemotePathToLocal(
                        $remoteFilePath, $remotePath, $localPath)
                $localFileDir = (Split-Path -Parent $localFilePath) 
                New-Item -ItemType directory -Path $localFileDir -Force | Out-Null 
                $source = [WinSCP.RemotePath]::EscapeFileMask($remoteFilePath)
                $session.GetFiles($source, $localFilePath).Check()
                Add-Content $listPath $remoteFilePath
                $count++
                Write-Host "Downloaded."
            }
        }
        # Results 
        # New files were found on the remote side
        if ($count -gt 0)
        {
            Write-Host "Done. Downloaded $count files. These files existed already: $filesNow"
            # Send an email
            Send-MailMessage @mailParams -Body "The FTP import job has finished. $count files were downloaded."
        }
        # No new files were found
        else
        {
            Write-Host "Done, no new files found. These files existed already: $filesNow"
            #Send an email
            Send-MailMessage @mailParams -Body "The FTP import job has finished, but didn't find any new files to download."
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
    $result = 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"

    # Send email on script error
    try{
        Send-MailMessage @mailParams -Body "ERROR: The FTP import script failed. Error: $($_.Exception.Message)" -Subject "FTP Import - FAILED - $(Get-Date -Format g)"
    }
    catch{
        Write-Host "Failed to send error email: $($_.Exception.Message)"
    }

    $result = 1
}
# Pause if -pause switch was used
if ($pause)
{
    Write-Host "Press any key to exit..."
    [System.Console]::ReadKey() | Out-Null
}
exit $result
