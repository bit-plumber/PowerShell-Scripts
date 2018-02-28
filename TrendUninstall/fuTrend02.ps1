# Filename:  fuTrend02.ps1
#
# Purpose:   Uninstall Trend Micro Officescan XG because they are an awful awful company 
#            that forced me to create a script to do their job for them.
#
# Author:    @bit_plumber
#
# Date:      2018.02.28
#
# Resources: https://success.trendmicro.com/solution/1039283-uninstalling-clients-or-agents-in-officescan-osce
#            https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process?view=powershell-6
#            https://stackoverflow.com/questions/28481811/how-to-correctly-check-if-a-process-is-running-and-stop-it
#            https://stackify.com/powershell-commands-every-developer-should-know/
#
#
# Milestones: Ver0.1   - Successfully completed uninstallation of TM andd install of Sophos
#                        x86 Windows 10 VM. (2018.02.27)
#             
#             Ver0.2   - Successfully completed uninstallation of TM andd install of Sophos
#                        x86 & x64 Windows 10 VMs. Rewrote code to not branch for x86 or x64, but to check
#                        whether x86 or x64 filestructure is in place and call 
#                        appropriate commands where they differ. (2018.02.28)
#
#
#
# SET VARIABLES
#
# Replace with the file location on your network for the below files.  
# See readme.txt for more info.
#
$SRCPTH = "\\SERVER\SHARE"
$SOPHOS = "$SRCPTH\SophosSetup_EndptIX.exe"
$KEYFILE = "$SRCPTH\TMRegKeys.txt"
$SUBKEYS = "$SRCPTH\TMSubKeys.txt"
$PROCFILE = "$SRCPTH\TMProcList.txt"
#
# Set Local Host Directory Variables
$PFx86 = "C:\Program Files\Trend Micro"
$PFx64 = "C:\Program Files (x86)\Trend Micro"
$PDATA = "C:\ProgramData\Trend Micro"
#
#
# Determines if local host is x86 or x64
$PROCARC = $env:PROCESSOR_ARCHITECTURE
#
# Enumerate all Users profiles on local host.  Will be used during clean-up phase
$users = Get-ChildItem C:\Users
#
#
#
# Force Unload of OfficeScan Agent and Shutdown Trend Processes for x86 or x64 platforms.
#
#Verify if PccNTMon.exe exists in Program Files folder, if so, unload it.
$CHKFILE = "C:\Program Files\Trend Micro\OfficeScan Client\PccNTMon.exe"
$FILEEXISTS = Test-Path $CHKFILE
If($FILEEXISTS -eq $true)
    {
        #Run the Unload switch against PccNTMon.exe, supplying the unload password ($PASSWORD) if one exists.
        & 'C:\Program Files\Trend Micro\OfficeScan Client\PccNTMon.exe' '-n' '*YOURPASSWORD*'
        # Allow time for this process to complete.  TMBMSRV must be stopped before any other services can be.
        Sleep 120
    }
#Verify if PccNTMon.exe exists in Program Files (x86), if so, unload it.
$CHKFILE = "C:\Program Files (x86)\Trend Micro\OfficeScan Client\PccNTMon.exe"
$FILEEXISTS = Test-Path $CHKFILE
If($FILEEXISTS -eq $true)
    {
        #Run the Unload switch against PccNTMon.exe, supplying the unload password ($PASSWORD) if one exists.
        & 'C:\Program Files (x86)\Trend Micro\OfficeScan Client\PccNTMon.exe' '-n' '*YOURPASSWORD*'
        # Allow time for this process to complete.  TMBMSRV must be stopped before any other services can be.
        Sleep 120
    }
#
# Verify All Trend Micro Services/Processes Are Stopped
$PROCS = Get-Content $PROCFILE
foreach ($PROC in $PROCS)
    {
        Get-Service $PROC -ErrorAction SilentlyContinue | Stop-Service -Force
        Get-Process $PROC -ErrorAction SilentlyContinue | Stop-Process -Force
    }
#
# Allow time for processes to release locks on file
Sleep 30   
#
# Clean-up of Trend Files and Folders in Program Files, if they exist.
$CHKDIR = $PFx86
$DIREXISTS = Test-Path $CHKDIR
If($DIREXISTS -eq $true)
    {
        Remove-Item -Path $PFx86 -Recurse -Force -ErrorAction SilentlyContinue
    }
#
# Clean-up of Trend Files and Folders in Program Files (x86), if they exist.
$CHKDIR = $PFx64
$DIREXISTS = Test-Path $CHKDIR
If($DIREXISTS -eq $true)
    {
        Remove-Item -Path $PFx86 -Recurse -Force -ErrorAction SilentlyContinue
    }
#
#
# Clean-up of Trend Files and Folders in ProgramData, if they exist
#
$CHKDIR = $PDATA
$DIREXISTS = Test-Path $CHKDIR
If($DIREXISTS -eq $true)
    {        
        Remove-Item -Path "C:\ProgramData\Trend Micro" -Recurse -Force -ErrorAction SilentlyContinue
    } 
#
#
# Clean-up Trend Files and Folders in each Users %LocalAppdata% directory
#
foreach ($user in $users)
    {
        $folder = "$($user.fullname)\AppData\Local\Trend Micro"
            If (Test-Path $folder) 
            {
                Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
            }
    }
#
# Remove Trend Micro Registry Keys
#
$KEYS = Get-Content $KEYFILE
foreach($KEY in $KEYS)
{
    $KEYEXISTS = Test-Path $KEY
    If($KEYEXISTS -eq $true)
    {
        Remove-Item $KEY -Recurse -Force -ErrorAction SilentlyContinue                     
    }
}
#
# Remove Trend Micro Values from Misc. Keys
#
$VALS = Import-Csv $SUBKEYS
foreach($VAL in $VALS)
    {
        $VALEXISTS = Test-Path $VAL.KEY
        If($VALEXISTS -eq $true)
        {
            Remove-ItemProperty -Path $VAL.KEY -Name $VAL.VALUE -Force
        }
    }
#
