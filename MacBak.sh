#!/bin/bash
#---------------------------------------------------------------------------------------
#********************* "MacBak" Backup and Restore Script v1.1 *************************
#*********************           Dave Culp                ******************************
#*********************      Created: 05_29_2013           ******************************
#---------------------------------------------------------------------------------------
#Title
echo "-------------------------------------------------------------------"
echo "******|-MacBak- Backup and Restore Script v1.1 - TehCulprit|*******"
echo "-------------------------------------------------------------------"
echo ""
echo " What would you like to do? (B or R)"
echo "( B )ackup"
echo "( R )estore"
echo ""
read caseNumber

if [ "$caseNumber" = "B" ] || [ "$caseNumber" = "b" ]
	then
		# ---------------------- ******* Backup Portion ******* ------------------------

		#Mount Server
		echo " A Dialog Will Appear to Mount the Backup Server lumsus01..."
		sleep 1

		osascript  -e 'tell application "Finder" to mount volume "afp://lumsus01/Customer Backups"'


		#Create folder on lumsus01 for backup to be stored in
		echo "Please enter the RITM number of the current request to title the backup folder: "
		read ritm
		sleep 2
		mkdir /Volumes/Customer\ Backups/$ritm/

		# Backup Directory Variable
		backupDir="/Volumes/Customer Backups/$ritm"

		#backup the data
		echo "Which Volume is the data stored on that you would like to backup? (case sensitive) "
		ls /Volumes/
		read volumeName
		volChoice=/Volumes/$volumeName/Users
		echo ""
		echo "Which user profile would you like to backup data FROM? (case sensitive) "
		ls "$volChoice"
		read backupName

		# User folder Directory Variable
		userFolder=$volChoice/$backupName

		mkdir "$backupDir/Desktop/"
		rsync --verbose --recursive --progress "$userFolder/Desktop/" "$backupDir/Desktop/"
		mkdir "$backupDir/Documents/"
		rsync --verbose --recursive --progress "$userFolder/Documents/" "$backupDir/Documents/"
		mkdir "$backupDir/Downloads/"
		rsync --verbose --recursive --progress "$userFolder/Downloads/" "$backupDir/Downloads/"
		mkdir "$backupDir/Movies/"
		rsync --verbose --recursive --progress "$userFolder/Movies/" "$backupDir/Movies/"
		mkdir "$backupDir/Music/"
		rsync --verbose --recursive --progress "$userFolder/Music/" "$backupDir/Music/"
		mkdir "$backupDir/Pictures/"
		rsync --verbose --recursive --progress "$userFolder/Pictures/" "$backupDir/Pictures"
		echo "---------------------------------------------------------------------------------------------------------------"
		echo "The Desktop, Documents, Downloads, Movies, Music, and Pictures folders have copied."
		echo "Please be sure to check for any data on the root or any other non-standard locations and back them up manually."
		echo "---------------------------------------------------------------------------------------------------------------"
		sleep 5

		# ---------------------- ******* End Backup Portion ******* ------------------------

	else
		# ---------------------- ******* Restore Portion ******* ------------------------

		echo "Is the data your restoring on lumsus01 or on the local machine? (S or L)"
		echo "( S )erver - lumsus01"
		echo "( L )ocal (Usually Liberty-Owned Pickups)"
		read location

		if [ "$location" = "S" ] || [ "$location" = "s" ]
			then
				#Mount Server
				echo " A Dialog Will Appear to Mount the Backup Server lumsus01..."
				sleep 1

				osascript  -e 'tell application "Finder" to mount volume "afp://lumsus01/Customer Backups"'
		
				#Collect RITM#
				read -p "What is the RITM number of the data you would like to restore? (Case sensitive) " ritm
				restoreFrom="/Volumes/Customer Backups/$ritm"
		
				#Find if user profile exists to restore TO
				read -p "Does the user profile already exist on the local machine? (Y or N) " profile
				if [ "$profile" = "Y" ] || [ "$profile" = "y" ]
					then
						ls /Users/
						read -p "Which user would you like to restore TO? (Case Sensitive) " userChoice
				
						echo "Copying data to selected user's Desktop..."
						sleep 3
						fDate="$(date +%Y-%m-%d_$ritm)"
						mkdir /Users/$userChoice/Desktop/$fDate/
						restoreTo="/Users/$userChoice/Desktop/$fDate"
						rsync --verbose --recursive --progress "$restoreFrom/" $restoreTo/
						chown -R $userChoice $restoreTo
						#rename folder on server with Date-Stamp
						mv "/Volumes/Customer Backups/$ritm/" "/Volumes/Customer Backups/$fDate/"
						homeFolder="/Users/$userChoice"
				
						#Place data where it belongs
						mv -n $restoreTo/Desktop/* $homeFolder/Desktop/
						mv -n $restoreTo/Documents/* $homeFolder/Documents/
						mv -n $restoreTo/Downloads/* $homeFolder/Downloads/
						mv -n $restoreTo/Music/* $homeFolder/Music/
						mv -n $restoreTo/Movies/* $homeFolder/Movies/
						mv -n $restoreTo/Pictures/* $homeFolder/Pictures/
				
						echo "Data restored successfully."

					else
						#Copy data from lumsus01 to current user's Desktop
						echo "Copying data to current user's Desktop..."
						user=$(logname)
						sleep 3
						fDate="$(date +%Y-%m-%d_$ritm)"
						mkdir /Users/$user/Desktop/$fDate/
						restoreTo="/Users/$user/Desktop/$fDate"
						rsync --verbose --recursive --progress "$restoreFrom/" $restoreTo/
						#rename folder on server with Date-Stamp
						mv "/Volumes/Customer Backups/$ritm/" "/Volumes/Customer Backups/$fDate/"
		
				fi
	
			else
				read -p "ARE YOU LOGGED IN AS THE DOMAIN USER THAT NEEDS DATA RESTORED WITH ADMIN RIGHTS? (Y or N) " answer
				
				if [ "$answer" = "Y" ] || [ "$answer" = "y" ]
					then
						echo "Please enter the exact path to the user's backup folder (Case sensitive): "
						echo "I think your data is stored at:"
						find /Users -name "20*-*-*_*"
						read dataPath
						user=$(logname)
						chown -R $user $dataPath
						homeFolder="/Users/$user"
		
						#Place data where it belongs
						mv -n $dataPath/Desktop/* $homeFolder/Desktop/
						mv -n $dataPath/Documents/* $homeFolder/Documents/
						mv -n $dataPath/Downloads/* $homeFolder/Downloads/
						mv -n $dataPath/Music/* $homeFolder/Music/
						mv -n $dataPath/Movies/* $homeFolder/Movies/
						mv -n $dataPath/Pictures/* $homeFolder/Pictures/
				
						echo "Data restored successfully."		
						
					else
						echo "Please restart script when logged into domain user's account with admin privileges"
						exit 0
				fi
		fi
# ---------------------- ******* End Restore Portion ******* ------------------------
fi



sleep 5
#Un-Mount Server
echo ""
echo "Unmounting server..."
sleep 3
sudo umount /Volumes/Customer\ Backups/
echo ""
echo "Server unmounted, or was not mounted initially. Press any key to exit the script."
read key
exit 0

