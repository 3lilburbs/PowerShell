<#
Example from the MS documentation at https://learn.microsoft.com/en-us/powershell/module/remotedesktop/update-rdvirtualdesktopcollection?view=windowsserver2025-ps
Update-RDVirtualDesktopCollection [-CollectionName] <string> -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm]  [<CommonParameters>]
Update-RDVirtualDesktopCollection [-CollectionName] <string> -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> -StartTime <datetime> -ForceLogoffTime <datetime> [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm]  [<CommonParameters>]
Update-RDVirtualDesktopCollection [-CollectionName] <string> -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> -ForceLogoffTime <datetime> [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm]  [<CommonParameters>]
#>

# Original method was using backticks, which can be fragile as white spaces can break the flow from one parameter to another. 
Update-RDVirtualDesktopCollection `
-CollectionName "Pooled Desktops" `
-VirtualDesktopTemplateName "RDS-TEST-TEMPLATE" `
-VirtualDesktopTemplateHostServer "RDS-TEST-VHOST.RDS-TEST.CO.UK" `
-ForceLogoffTime "2026-05-12 23:00" `
-ConnectionBroker "RDS-TEST-AD.RDS-TEST.CO.UK" `
-Force

# It's cleaner using "splatting" as below. 'Shift + Alt + F' will format this is VSCode in a readable way.
$collectionParams = @{
  CollectionName                   = "Pooled Desktops"
  VirtualDesktopTemplateName       = "RDS-TEST-TEMPLATE"
  VirtualDesktopTemplateHostServer = "RDS-TEST-VHOST.RDS-TEST.CO.UK"
  ForceLogoffTime                  = "2026-05-12 23:00"
  ConnectionBroker                 = "RDS-TEST-AD.RDS-TEST.CO.UK"
  WhatIf                           = $false
  Force                            = $false
}
# Run the update with the specified parameters.
Update-RDVirtualDesktopCollection @collectionParams
