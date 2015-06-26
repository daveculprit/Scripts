#                           Dave Culp Feb. 3rd 2015
# This script runs in a task sequence and sets the Assigned user to the Description field in AD
# And sets the serialNumber attribute in AD.


# Import AD Module into powershell - The files had to be manually copied to the boot wim and 
# are not included in PS for PE by default
Import-Module ActiveDirectory -Force

# Create TS object to read/write variables from the TS
$TsENV=New-Object -ComObject Microsoft.SMS.TSEnvironment

# Create a user cred object that can be used to interact with AD
$ADUn="SENSENET\joinmac"
$password="j01nm3n0W"
$secstr=New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred=new-object -typename System.Management.Automation.PSCredential -argumentlist $ADUn, $secstr

# Read values
$AssignedUser=$TsENV.Value("AssignedUser")
$CompName=$TsENV.Value("OSDComputerName")
$serialNumber=$TsENV.Value("SerialNumber")

#Set Assigned User
Set-ADComputer -Identity $CompName -Description "Assigned User: $AssignedUser" -Server University.liberty.edu -Credential $cred

#Set serialNumber
$CompInst=Get-ADComputer -Identity $CompName -Property serialnumber -Server University.liberty.edu -Credential $cred
$CompInst.serialNumber="$serialNumber"
Set-ADComputer -Instance $CompInst -Server University.liberty.edu -Credential $cred