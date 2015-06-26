#----- David Culp -----
#----- 2014.05.08 -----
# This script injects Windows Updates and/or drivers into a designated .wim file using DISM

#This first section must be modified to your environment paths:
#Path where updates/Drivers are stored:
$UpdatesPath = "S:\WinUpdates\Win7x64_FacStaff\x64WimUpdates\cabs\*"
#Folder to mount wim to be updated:
$MountPath = “C:\TempMount\Mount”
#Path to wim that needs updated:
$WimFile = “S:\win7x64FullOffice.wim”
#-------------------------------------------------------------


#Mount wim and install updates:
DISM /Mount-Wim /WimFile:$WimFile /index:1 /Mountdir:$MountPath
$UpdateArray = Get-Item $UpdatesPath
$count = 1
ForEach ($Updates in $UpdateArray)
{
DISM /image:$MountPath /Add-Package /Packagepath:$Updates
Start-Sleep –s 10
Write-Host "Applied Update $count"
$count = $count + 1
}
Write-Host "All Updates Applied to WIM"

#Unmount and cleanup
DISM /Unmount-Wim /Mountdir:$MountPath /commit
DISM /Cleanup-Wim
Write-Host "Wim has been unmounted and cleaned up."