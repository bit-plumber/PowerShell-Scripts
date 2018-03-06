# Universal PowerShell 5.1 Upgrade Tool (PS51upg_univ01.ps1)
Used to check if PowerShell 5.1 is installed on a host computer and if not, install it along with any necessary prerequisites.  This script relies on WSUSOffline, please download it from their website:  http://www.wsusoffline.net/

In summary, the script accomplishes the following:

  On a Windows 7 Computer:
	* Checks if Windows Management Framework 5.1 is installed  
	* If not, check that the prerequisites for WMF 5.1 are installed.
	* If not, install missing prerequisites.
	* Once prerequisites are met, install WMF 5.1


Disclaimer:  I am no PowerShell guru.  In fact the vast majority of my PowerShell knowledge is baked into this script.  
			 If you see a better way to do anything, please feel free to contribute.


## To Do

	* Create Windows Restore Point before any actions are taken
	* Verify working on x64 Windows 7 computer
	* Create config file to supply server names, passwords, etc.
	* Build out WMF 3 uninstallation
  * Configure for Win10 Computers
	* etc.
