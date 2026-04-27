$disconnectedSessions = Get-RDUserSession | Where-Object {$_.SessionState -like "STATE_Disconnected"}
foreach($session in $disconnectedSessions){Invoke-RDUserLogoff -HostServer $session.HostServer -UnifiedSessionID $session.UnifiedSessionId -Force}
