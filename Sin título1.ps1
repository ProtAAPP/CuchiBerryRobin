﻿# Define a WMI event query, that looks for new instances of Win32_LogicalDisk where DriveType is "2"
# http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
$Query = "select * from __InstanceCreationEvent within 5 where TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 2";

# Define a PowerShell ScriptBlock that will be executed when an event occurs
$Action = { & "C:\Users\hernandezcfran\OneDrive - Ayuntamiento de Madrid\Code\CuchiBerryRobin\USB_in.ps1";  };

# Create the event registration
Register-WmiEvent -Query $Query -Action $Action -SourceIdentifier USBFlashDrive;