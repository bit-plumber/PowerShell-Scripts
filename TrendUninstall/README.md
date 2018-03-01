# TrendUninstall (fuTrend.ps1)
A script I was forced to write to remove the Trend Micro OfficeScan XG client from Win7(coming soon) and Win10 workstations.

None of the methods that Trend Micro provided would work in my environment, so I took upon myself to build a better sledgehammer.  
In summary, the script accomplishes the following:

	* Unloads the Trend OfficeScan client.  
	* Closes all Trend Micro Processes and Services
	* Deletes all files and folders associated with Trend Micro
	* Removes all Registry entries associted with Trend Micro
	

Disclaimer:  I am no PowerShell guru.  In fact the vast majority of my PowerShell knowledge is baked into this script.  
			 If you see a better way to do anything, please feel free to contribute.


## To Do

* Create Windows Restore Point before any actions are taken
* Removal of Non-Plug-And-Play Drivers on Win7 machines
* Create config file to supply server names, passwords, etc.
* Better methods of timing than default Sleep 120/30/etc.
* etc.