# Specify the host servers to check for VM's
# List all VM's
# Put together a list of active and inactive connections
# List of VM's in a stopped, saved or running state
# 

# List of Hyper-V hosts.
$hyperVHosts = @("RDS-VH01", "RDS-VH02", "RDS-VH03")

# Get all active and disconnected RDS user sessions.
$activeSessions = Get-RDUserSession | Where-Object { $_.SessionState -eq "STATE_ACTIVE" }
$disconnectedSessions = Get-RDUserSession | Where-Object { $_.SessionState -eq "STATE_DISCONNECTED" }

# Create summary counters list of VM's.
$vmSavedCount = 0
$vmSavedList = @()

# Loop through each Hyper-V host server specified in $hyperVHosts array.
foreach($hyperVHostServer in $hyperVHosts){
    # Print update to console.
    Write-Host "Getting VM's on host server $hyperVHostServer..."
    # Get the VM's running on each host specified in $hyperVHosts array.
    $vmList = Get-VM -ComputerName $hyperVHostServer
    # Print update to console.
    Write-Host "Found these VM's on $hyperVHostServer..."
    foreach($vm in $vmList){
        Write-Host $vm.Name
    }
}

# Output total counts
Write-Host $activeSessions.Count()
Write-Host $disconnectedSessions.Count()
