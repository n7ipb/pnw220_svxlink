#!/bin/bash
# config_pi_part1.sh will prepare your system for installing SvxLink 
# It should be run on a fresh install of raspian as user 'pi'
# and will update the os, create ram disks and setup a second admin
# user.   It will then lock down the 'pi' user so it can no longer
# be used to remotely log in.
#
set -e

prepare_disk () {
    echo "To prevent premature SD card failure isolate frequently written to directories by"
    echo "making them into ram disks"
    echo "/tmp, /var/tmp, /var/log, /var/spool/svxlink"
    echo "The downside is that log files don't survive a reboot"
    echo
    echo "#temp filesystems for all the logging and stuff to keep it out of the SD card
tmpfs    /tmp    tmpfs    defaults,noatime,nosuid,size=5m    0 0
tmpfs    /var/log    tmpfs    defaults,noatime,nosuid,mode=0755,size=100m    0 0
tmpfs    /var/spool/svxlink    tmpfs    defaults,noatime,nosuid,size=100m    0 0" | sudo tee -a /etc/fstab
    echo done

    echo "Add $USER user"

    echo "Create a new user so we can disable the common user (pi) that everyone knows about"
    echo "default = svx_admin"
    read -p "Username: " USER
    echo
    USER=${USER:-svx_admin}
    echo 
    echo "Add $USER user"
    sudo sudo /usr/sbin/useradd --shell /bin/bash --groups adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi,tty -m $USER
    echo
    echo "Set Password for $USER"
    sudo passwd $USER
    echo
    echo "Add $USER to sudo"
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/010_svx_admin-nopasswd')
    echo
    echo "Disable login for user 'pi'"
    sudo passwd --lock pi
    echo
    echo
    echo "Create Projects and bin directory for $USER"
    sudo mkdir /home/$USER/Projects
    sudo mkdir /home/$USER/bin
    sudo chown $USER:$USER /home/$USER/Projects
    sudo chown $USER:$USER /home/$USER/bin
    }

# We assume that the scripts been run before if not being run as user 'pi'
#    
if [ "$USER" != "pi" ]; then
   echo "Not running as user 'pi' so we assume this has been run before"
   echo "aborting execution"
   exit
fi

# Update packages 
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get -y install git vim nftables libjsoncpp1 libjsoncpp-dev bc snmpd fail2ban python3-pip

echo "Run raspi-config to set local/timezone/keyboard and change the password and hostname."
echo ""
echo "****DO NOT REBOOT**** from within raspi-config."
echo "****DO NOT REBOOT**** from within raspi-config."
echo "****DO NOT REBOOT**** from within raspi-config."
echo "****DO NOT REBOOT**** from within raspi-config."
echo "****DO NOT REBOOT**** from within raspi-config."
echo " Exit normally and let this script finish then reboot."
echo "Do you wish to run raspi-config?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo raspi-config; break;;
        No ) break;;
    esac
done


echo "Do you wish to finish customizing the image?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) prepare_disk; break;;
        No ) break;;
    esac
done

echo "The system will now reboot and you must log back in as $USER"
echo "This is a good point to take the time to install an SSH key"
echo "for the new user to make your life easier"

sleep 5
echo "Install complete, rebooting."
sleep 5
sudo reboot
