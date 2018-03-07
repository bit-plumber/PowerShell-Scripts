#
# Filename:      PS51upg_univ.ps1
#
# Purpose:       Check any Windows 7/10 box for it's current installed version of PowerShell /
#                Windows Management Framework and upgrade to 5.1 if is not currently installed.
#
# Author:        @bit_plumber
#
# First Update:  2018.03.01
# Last Update:   2018.03.06
#
#
# Resources:     https://stackify.com/powershell-commands-every-developer-should-know/
#                https://docs.microsoft.com/en-us/powershell/scripting/setup/windows-powershell-system-requirements?view=powershell-6
#                https://docs.microsoft.com/en-us/powershell/wmf/5.1/install-configure
#                https://docs.microsoft.com/en-us/dotnet/framework/deployment/deployment-guide-for-developers#command-line-options
#                https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions
#                https://stackoverflow.com/a/12621314
#
#
#
# Milestones: Ver0.1 -  Successfully check for presence of Windows Management Framework
#                       5.1, if it does not exist install any necessary prerequisites and
#                       then install WMF5.1 on an x86 Win7 computer.  2018.03.06
#
#
#
# If set to "Continue" errors will prompt.  If set to "SilentlyContinue", script will continue if error is thrown.
$defaultaction = "SilentlyContinue"
#
#
# HostOS-Info() parses a registry string for OS information and returns a subset we are looking for.
#
function HostOS-Info
    {
        # Pull all OS Properties from the Registry into an array.
        $HostOSRaw = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction $defaultaction)
        #
        # Create trimmed down array with pertinent information to return from function.
        $HostOS = "" | Select-Object -Property ProductName,CSDVersion,Arch,CurrentVersion,CurrentBuild,ReleaseId,CurrentMajorVersionNumber,CurrentMinorVersionNumber
        $HostOS.CurrentVersion = $HostOSRaw.CurrentVersion
        $HostOS.ProductName = $HostOSRaw.ProductName
        $HostOS.CSDVersion = $HostOSRaw.CSDVersion
        $HostOS.CurrentMajorVersionNumber = $HostOSRaw.CurrentMajorVersionNumber
        $HostOS.ReleaseId = $HostOSRaw.ReleaseId
        $HostOS.CurrentBuild = $HostOSRaw.CurrentBuild
        $HostOS.CurrentMajorVersionNumber = $HostOSRaw.CurrentMajorVersionNumber
        $HostOS.CurrentMinorVersionNumber = $HosOSRaw.CurrentMinorVersionNumber
        $HostOS.Arch = $env:PROCESSOR_ARCHITECTURE
        #
        return $HostOS
    }
#
# dotNet-Info() parses the registry string for .Net Framework information and returns a subset we are looking for.
#
function dotNet-Info
    {
        # Pull all .Net Framework Properties from the Registry into an array.
        $dotNetRaw = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\')
        # Need to figure out how to grab .net info for belo v4/5
        #
        # Create trimmed down array with pertinent information to return from function.
        $dotNetHost = "" | Select-Object -Property Version,Release,Install
        $dotNetHost.Version = $dotNetRaw.Version
        $dotNetHost.Release = $dotNetRaw.Release
        $dotNetHost.Install = $dotNetRaw.Install
        #
        return $dotNetHost
    }

#
# PSver-Info() parses the $PSVerstiontable.PSVersion environmental variable
function PSver-Info
    {
        $psVer = $PSVersiontable
        #
        return $PSVer
    }
#
# wmfPrereqCheck() runs through the prerequisites for install WMF5.1, and creates an array variable to be passed back to script detailing which prerequisites need to me met.
function wmfPrereqCheck
  {
    $OSupd = $null
    $remWFM3 = $null
    $dotNetUpd = $null
#
#
  If($OSInfo.CurrentVersion -eq "6.3")
  {
    $OSupd = $false ##### Need to come back and work through W10
  }
  ElseIf($OSInfo.CurrentVersion -eq "6.1" -and $OSInfo.CurrentBuild -ne "7601")
  {
    $OSupd = $true
  }
  Else
  {
    $OSupd = "Unsupported"
  }
#
# Verify WMF 3.0 is not installed.  WMF 5.0+ will not install if WMF 3.0 is installed.  ######  STILL NEED TO CREATE UNINSTALL script
  $WMF3 = Get-WmiObject -Query "select * from Win32_QuickFixEngineering where HotFixID = 'KB2506143'"
  If($WMF3)
  {
    $remWMF3 = $true
  }
  Else
  {
    $remWMF3 = $false
  }
  #
  # Verify the latest .Net Framework is the most current 4.7.x release, currently 4.7.1
  $dotNetVer = $dotNetInfo.Version
  If($dotNetVer -eq "4.7.1")
  {
    $dotNetUpd = $false
  }
  Else
  {
    $dotNetUpd = $true
  }
  # Return test results to script.
  $prereqCheck = "" | Select-Object OSupd, remWMF3,dotNetUpd
  $prereqCheck.OSupd = $OSupd
  $prereqCheck.remWMF3 = $remWMF3
  $prereqCheck.dotNetUpd = $dotNetUpd
  #
  return $prereqCheck
}
#
# function() creates a Pause function similar to that in CMD batch scripts
function Pause
($Message = "Press any key to continue . . . ")
{
  if ((Test-Path variable:psISE) -and $psISE)
  {
    $shell = New-Object -ComObject "WScript.Shell"
    $button = $shell.Popup("Click OK to continue.", 0, "Script Paused", 0)
  }
  else
  {
    Write-Host -NoNewline $Message
    [void][System.Console]::ReadKey($true)
    Write-Host
  }
}
#
# Convert Function Returns into Global Variables
#
  $OSInfo = HostOS-Info
  $dotNetInfo = dotNet-Info
  $psVerInfo = PSver-Info
  $prereqTestInfo = wmfPrereqCheck
#
# Do All The Things
#
  CLS
#
# Check if host is running Windows Management Framework v5.1.  If not, install it along with any necessary prerequisites.
  PSver-Info
  If($psVerInfo.PSVersion -ge "5.1")
  {
    Write-Host "Congratulations, no need to upgrade.  You have PowerShell v5.1 or greater Installed"
  }
  ElseIf($psVerInfo.PSVersion -lt "5.1")
  {
    #Run Functions to gather Prerequisite Info
    HostOS-Info
    dotNet-Info
    wmfPrereqCheck
  }
#
# Use WSUSOffline to install missing prerequisites and Windows Management Framework / PowerShell 5.1
#
# Copy WSUSOffline files for host build to host computer
# You will need to download WSUSOffline and run UpdateGenerator.exe to create update folder for each possible device type.  Store the output directories on a file server accessible to the host machine with ANONYMOUS LOGIN given read access.  Set $srcPath to this share.
#
  $srcPath = "\\SERVER\SHARE\win7x86_dotNet_wmf5"
  $dstPath = "C:\temp"
  if(!(Test-Path -Path $dstPath))
  {
    New-Item $dstPath -Type Directory -Force
  }
  Copy-Item -Path $srcPath -Destination $dstPath -Recurse -Force -ErrorAction $defaultaction
  #
  # Call WSUSOffline with switches to create automated installation of prereqs
  # This will exit this script, reboot the computer and begin the WSUSOffline upgrade PROCESSOR_ARCHITECTURE
  #
  cmd.exe /C " "$dstPath\win7x86_dotNet_wmf5\update.cmd" /verify /skipieinst /instdotnet4 /instpsh /instwmf /seconly /autoreboot"
