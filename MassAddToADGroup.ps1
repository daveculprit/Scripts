$getCompNames = Get-Content .\pilotGroup.txt 
Foreach ($comp in $getCompNames)
{
   Add-ADPrincipalGroupMembership -identity $comp -memberof 'Patch Pilot Machines'
   }
 