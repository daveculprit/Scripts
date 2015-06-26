#                           Dave Culp Feb. 3rd 2015
# This script deletes AD records\runs in a task sequence to assist in setting an OU in AD for newly imaged machines
#Dependant on Task Sequence variables "OUName" and "OSDComputerName" OUNAme is a collection variable.

# The line below can be enabled to accept command line arguments for running script standalone

#param([string]$UserName,[string]$CompName,[string]$OUName="University Computers")

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
$OUName=$TsENV.Value("OUName")
$CompName=$TsENV.Value("OSDComputerName")

#Check if record exists in AD and delete if so
$CompToDelete=$(try {Get-ADComputer -Identity $CompName -Server University.liberty.edu -Credential $cred} catch {$null})
if ($CompToDelete -ne $null){
    Remove-ADComputer -Identity $CompToDelete -Server University.liberty.edu -Credential $cred -Confirm:$false}
     
# Get OU Object if exists otherwise set to unsorted computers
$OUObj=$(try {Get-ADOrganizationalUnit -filter 'Name -like $OUName' -Server University.liberty.edu -Credential $cred} catch {$null})
if ($OUObj -ne $null){
    $OUObj=$OUObj.tostring()
    }
else{
    $OUObj="OU=Unsorted Computers,OU=University Computers,DC=University,DC=liberty,DC=edu"
    }

#Save OU Value to a TS variable for use in the Apply Network Settings Task
$TsENV.Value("OUToJoin")=$OUObj
