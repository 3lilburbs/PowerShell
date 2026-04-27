$wingetsource = get-appxpackage | Where-Object{$_.Name -eq "Microsoft.Winget.Source"}
$wingetpkg = $wingetsource.PackageFullName
remove-appxpackage $wingetpkg
