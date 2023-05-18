#!/bin/bash
# author: 4n0nym4u5

red="\e[0;31m"
green="\e[0;32m"
off="\e[0m"
bg="\e[40;38;5;82m"
gb="\e[30;48;5;82m"

SHARE_FILE ()
{
	clear
	service apache2 start
	echo -e "$red [$green+$red]$off SHARE FILE";
    echo -e "$red [$green+$red]$off Enter the path to the file : \c";
    read DIR
    echo -e "DIR=$DIR" >> /tmp/log.txt
    if [[ -f "$DIR" ]]
    then
        cp -f "$DIR" /var/www/html
    	FILE="$(basename $DIR)" 
    	echo -e '(new-object system.net.webclient).downloadfile("http://'$RASPI'/'$FILE'","C:/Shared/'$FILE'") ; exit' > /tmp/cmd.txt
		while read line; do	
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
            echo -e "$red [$green+$red]$off Sharing$red [$green $FILE $red]$off to $red[$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt
        done < "/tmp/hosts.txt"
		rm -f /var/www/html/"$FILE"
	elif [[ -d "$DIR" ]]
	then
    	FILE="$(basename $DIR)"
    	cd "$DIR" && cd ..
    	zip -r "/var/www/html/$FILE" "$FILE"
		service apache2 restart
		echo -e '(new-object system.net.webclient).downloadfile("http://'$RASPI'/'$FILE.zip'","C:/Shared/'$FILE.zip'")' > /tmp/cmd.txt
		echo -e 'Expand-Archive -Path C:/Shared/'$FILE'.zip -DestinationPath C:/Shared' >> /tmp/cmd.txt
		echo -e 'del C:/Shared/'$FILE'.zip ' >> /tmp/cmd.txt
		echo -e 'exit' >> /tmp/cmd.txt
		while read line; do	
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
            echo -e "$red [$green+$red]$off Sharing$red [$green $FILE $red]$off to $red [$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt
        done < "/tmp/hosts.txt"
		rm -f /var/www/html/"$FILE.zip"
    else
		echo -e "$red [$green✘$red]$off The path to the file or directory does not exist.";
	fi
}

SHUTDOWN_CLIENT () 
{
	clear
	echo -e "$red [$green+$red]$off SHUTDOWN CLIENT";
	echo -e "$red [$green+$red]$off Enter the reason to shutdown : \c";
	read MSG
	echo -e "$red [$green+$red]$off Enter the timeout period in seconds : \c";
	read SEC
	echo -e 'shutdown /s /t '$SEC' /c "'$MSG'" ; exit' > /tmp/cmd.txt
    while read line; do
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
            echo -e "$red [$green+$red]$off Shutting down$red [$green $IP $red]$off "; 
            nc "$IP" 8080 < /tmp/cmd.txt 
    done < "/tmp/hosts.txt"
}

INSTALL_SOFT ()
{
	clear
	echo -e "$red [$green+$red]$off Install software";
	service apache2 start
	echo -e "$red [$green+$red]$off Enter the path to the software : \c"; 
	read DIR
	echo -e "DIR=$DIR" >> /tmp/log.txt
	if [[ -f "$DIR" ]]
    then
        cp -f "$DIR" /var/www/html
    	FILE="$(basename $DIR)"
    	echo -e '(new-object system.net.webclient).downloadfile("http://'$RASPI'/'$FILE'","C:/Shared/'$FILE'")' > /tmp/cmd.txt
		echo -e 'Start-Process -FilePath "C:/Shared/'$FILE'" -ArgumentList "/S" ' >> /tmp/cmd.txt
		echo -e 'exit' >> /tmp/cmd.txt
		while read line; do	
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
            echo -e "$red [$green+$red]$off Installing$red [$green $FILE $red]$off in $red [$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt
        done < "/tmp/hosts.txt"
		rm -f /var/www/html/"$FILE"
	elif [[ -d "$DIR" ]]
	then
		echo -e "$red [$green+$red]$off Enter the setup file inside$red [$green"$DIR"$red]$off folder : \c";
		read SETUP
    	FILE="$(basename $DIR)"
    	cd "$DIR" && cd ..
    	zip -r "/var/www/html/$FILE" "$FILE"
		service apache2 restart
		echo -e '(new-object system.net.webclient).downloadfile("http://'$RASPI'/'$FILE.zip'","C:/Shared/'$FILE.zip'")' > /tmp/cmd.txt
		echo -e 'Expand-Archive -Path C:/Shared/'$FILE'.zip -DestinationPath C:/Shared' >> /tmp/cmd.txt
		echo -e 'del C:/Shared/'$FILE'.zip ' >> /tmp/cmd.txt
		echo -e 'Start-Process -FilePath "C:/Shared/'$FILE'/'$SETUP'" -ArgumentList "/S"' >> /tmp/cmd.txt
		echo -e 'exit' >> /tmp/cmd.txt
		while read line; do	
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
            echo -e "$red [$green+$red]$off Installing$red [$green $SETUP $red]$off in$red [$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt
        done < "/tmp/hosts.txt"
		rm -f /var/www/html/"$FILE.zip"
    else
		echo -e "$red [$green+$red]$off The path to the software does not exist.";
	fi
}

UNINSTALL_SOFT ()
{
	clear
	echo -e "$red [$green+$red]$off Uninstall software";
	echo -e "$red [$green+$red]$off Enter the name of the software : \c";
	read SOFTWARE
	echo -e "reg query HKLM\Software /v QuietUninstallString /s | findstr "$SOFTWARE" > log.txt" > /tmp/cmd.txt
	echo -e "(gc log.txt | select -Skip 1) | sc log.txt" >> /tmp/cmd.txt
	echo -e '$string = cat log.txt' >> /tmp/cmd.txt
	echo -e '$path = $($string.split()[-3..-3] + $string.split()[-2..-2])' >> /tmp/cmd.txt
	echo -e 'Start-Process -FilePath "$path" -ArgumentList "/S"' >> /tmp/cmd.txt
	echo -e "exit" >> /tmp/cmd.txt
	while read line; do	
            IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
            echo -e "$red [$green+$red]$off Uninstalling$red [$green $SOFTWARE $red]$off in$red [$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt
    done < "/tmp/hosts.txt"
}

BLOCK_WEBSITES ()
{
	clear
	echo -e "$red [$green+$red]$off Block websites on the client system.";
	echo -e "$red [$green+$red]$off Enter the website url (eg : www.example.com) : \c";
	read WEBSITE
	echo -e "WEBSITE=$WEBSITE" >> /tmp/log.txt
    echo -e 'echo "127.0.0.1 '$WEBSITE'" | Out-File -append C:/Windows/System32/drivers/etc/hosts' > /tmp/cmd.txt
    echo -e 'exit' >> /tmp/cmd.txt
	while read line; do
        IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
        echo -e "$red [$green+$red]$off Blocking$red [$green $WEBSITE $red]$off on $red[$green $IP $red]$off ";
       	nc "$IP" 8080 < /tmp/cmd.txt 
    done < "/tmp/hosts.txt"
}

UNDO ()
{
	source /tmp/log.txt
	clear
	if [[ "$CHOICE_PREV" -eq 0 ]]; then
		echo -e "$red [$green✘$red]$off Can't undo exit.";
	elif [[ "$CHOICE_PREV" -eq 1 ]]; then
		echo -e "$red [$green✘$red]$off Can't undo shutdown.";
	elif [[ "$CHOICE_PREV" -eq 2 ]]; then
		echo -e "$red [$green✘$red]$off Can't undo connecting to a client.";
	elif [[ "$CHOICE_PREV" -eq 3 ]]; then
		FILE="$(basename $DIR)"
		echo -e "del -Recurse -Force C:/Shared/"$FILE" " > /tmp/cmd.txt
		echo -e "exit" >> /tmp/cmd.txt
		while read line; do
			IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")";
			echo -e "$red [$green+$red]$off Deleting$red [$green $FILE $red]$off on $red[$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt;
		done < "/tmp/hosts.txt"
	elif [[ "$CHOICE_PREV" -eq 4 ]]; then
		UNINSTALL_SOFT

	elif [[ "$CHOICE_PREV" -eq 5 ]]; then
		#Need to remove last line of hosts file
		echo -e "$red [$green+$red]$off Undoing the last process";
		echo -e '$file = Get-Content C:/Windows/System32/drivers/etc/hosts' > /tmp/cmd.txt;
		echo -e '$output = $file[0..($file.count - 2)]' >> /tmp/cmd.txt;
		echo -e 'echo $output > C:/Windows/System32/drivers/etc/hosts' >> /tmp/cmd.txt
		echo -e "exit" >> /tmp/cmd.txt
		while read line; do
			IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")";
			echo -e "$red [$green+$red]$off Enabling$red [$green $WEBSITE $red]$off on $red[$green $IP $red]$off ";
			nc "$IP" 8080 < /tmp/cmd.txt;
		done < "/tmp/hosts.txt"
	elif [[ "$CHOICE_PREV" -eq 6 ]]; then
		INSTALL_SOFT
		
	elif [[ "$CHOICE_PREV" -eq 7 ]]; then
		echo -e "$red [$green✘$red]$off Can't undo twice ;)";
	else
		echo -e "$red [$green✘$red]$off Can't undo Invalid Option [ makes sense right :) ]";
fi
echo "CHOICE_PREV=7" > /tmp/log.txt
}
CONNECT_CLIENT ()
{
	clear
	echo -e "$red [$green+$red]$off CONNECT CLIENT";
	echo -e "$red [$green+$red]$off Clients online are : ";
	echo -e "$green$(cat /tmp/hosts.txt)$off";
	echo -e "$red [$green+$red]$off Enter the IP of the client : \c";
	read CLIENT
	echo -e "$red [$green+$red]$off Connecting to $red [$green $CLIENT $red]$off ";
	nc "$CLIENT" 8080
}
clear 
echo -e " "
echo -e "$bg ▄█          ▄████████ ███▄▄▄▄       $gb    ▀█████████▄   ▄█          ▄████████    ▄████████     ███      "
echo -e "$bg ███         ███    ███ ███▀▀▀██▄    $gb       ███    ███ ███         ███    ███   ███    ███ ▀█████████▄ "
echo -e "$bg ███         ███    ███ ███   ███    $gb       ███    ███ ███         ███    ███   ███    █▀     ▀███▀▀██ "
echo -e "$bg ███         ███    ███ ███   ███    $gb       ███    ███ ███         ███    ███   ███    █▀     ▀███▀▀██ "
echo -e "$bg ███         ███    ███ ███   ███    $gb      ▄███▄▄▄██▀  ███         ███    ███   ███            ███   ▀ "
echo -e "$bg ███       ▀███████████ ███   ███    $gb     ▀▀███▀▀▀██▄  ███       ▀███████████ ▀███████████     ███     "
echo -e "$bg ███         ███    ███ ███   ███    $gb       ███    ██▄ ███         ███    ███          ███     ███     "
echo -e "$bg ███▌    ▄   ███    ███ ███   ███    $gb       ███    ███ ███▌    ▄   ███    ███    ▄█    ███     ███     "
echo -e "$bg █████▄▄██   ███    █▀   ▀█   █▀     $gb     ▄█████████▀  █████▄▄██   ███    █▀   ▄████████▀     ▄████▀   "
echo -e "$bg ▀                                   $gb                  ▀                                               "
echo -e "$off "
GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')
RASPI=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo -e "$red [$green IP $red]$green = $red[$green $RASPI $red]$off"
echo -e "$red [$green GATEWAY $red]$green = $red[$green $GATEWAY $red]$off"
echo -e ""
echo -e "$red [$green\\a1$red]$off To shutdown the clients.";
echo -e "$red [$green\\a2$red]$off To connect to a particular client.";
echo -e "$red [$green\\a3$red]$off To share files to the clients.";
echo -e "$red [$green\\a4$red]$off To install software in the clients.";
echo -e "$red [$green\\a5$red]$off To block websites in the clients.";
echo -e "$red [$green\\a6$red]$off To uninstall software in the clients.";
echo -e "$red [$green\\a7$red]$off To Undo the last operation.";
echo -e "$red [$green\\a0$red]$off To exit.";
echo -e "$red [$green+$red]$off Enter your choice[0-7] : \c"
read CHOICE
if [[ $CHOICE -ne 0 && $CHOICE -ne 7 && $CHOICE -lt 7 ]]; then
	rm -f /tmp/hosts.txt /tmp/log.txt /tmp/cmd.txt
	echo "CHOICE_PREV=$CHOICE" > /tmp/log.txt
	nmap -n -sn "$GATEWAY"/24 --exclude "$RASPI","$GATEWAY" -oG - | awk '/Up$/{print $2}' > /tmp/hosts.txt
fi
case "$CHOICE" in
	1)
		SHUTDOWN_CLIENT
		;;
	2)
		CONNECT_CLIENT
		;;
	3)
		SHARE_FILE
		;;
	4)
		INSTALL_SOFT
		;;
	5)
		BLOCK_WEBSITES
		;;
	6)
		UNINSTALL_SOFT
		;;
	7)
		UNDO
		;;
	0)
		exit 1
		;;
	*)
		echo "CHOICE_PREV=-1" > /tmp/log.txt
		echo -e "$red [$green✘$red]$off Invalid Option.";
esac
sleep 5
./$(basename $0) && exit
