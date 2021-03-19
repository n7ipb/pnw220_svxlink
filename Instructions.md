#Instructions

Instructions for using crude scripts to use to create an image.
This file is new and the exact sequence has not been tested.
The scripts have been but are not robust and assume everything works.

Lots more work needs to be done to the scripts but what is here
works for now


******************************************

Download the latest raspberry pi OS.

Copy the image to an SD card - I use SanDisk 32GB High Endurance Video MicroSDHC cards,
https://www.amazon.com/gp/product/B07P14QHB7

Linux:  'sudo dd if=<imagefile>  of=/dev/<sdcard name>  bs=512M'

Mount the boot partition and Enable ssh by putting an empty file called 'ssh' in the boot partition.

Linux: 
sudo mount /dev/<sdcard partition 1> /mnt
sudo touch /mnt/ssh
sudo umount /mnt

Mount the main partition and copy the build info
Linux:
sudo mount /dev/sdcard partition 2> /mnt
sudo cp <tarball of ~/Projects/pnw220_svxlink> /mnt/home/pi
sudo umount /mnt

Make sure all the data is written to SD card
linux:
sync

Boot the RPi with the new image.
Login as user pi
Unpack the tarball
tar jxvf pnw220_svxlink_files.bz2

cd  ~/pnw220_svxlink/build_scripts

run the prep_user.sh script

This will update the OS and run raspi-config where you will have the opportunity 
to set a new hostname, language, timezone, etc.   You can also enable any needed 
interfaces (SPI,I2C,1-Wire)
Do NOT let raspi-config reboot.  The prep_user script will do that for you.

Then it will create a new user for administration work amd disable user 'pi' for security.  
Most attempts to hack a pi start with attempted logins as user 'pi'.

The pi will then reboot.

Log back in as the new user (svx_admin@newhostname)
This is a good point to install ssh public keys. (Highly, highly recommended)
On linux this is the 'ssh-copy-id user@hostname' command executed from the machine that
has the public/private keys.

Once logged in mv the /home/pi/pnw220_svxlink directory to ~/Projects

mv /home/pi/pnw220_svxlink ~/Projects

Change it's file owner to the new user.

chown -R svx_admin ~/Projects/pnw220_svxlink

cd ~/Projects/pnw220_svxlink/build_scripts

execute the install_svxlink.sh script

./install_svxlink.sh

This will update the repostiories, install needed support packages, create a svxlink user (no login created)
 and add the user 'svxlink' to various groups.

It will then pull the latest svxlink source, configure and build it.

Then it installs the binaries, man pages, default sound files and custom svxlink .tcl files.

Next support directories, crontab entries, updated vim.local, firewall rules, fail2ban, logrotate files, snmpd.conf
and enable loopback devices for the sound system.

Then it reboots

You can then log back in and configure and enable svxlink.

N7IPB - 03/15/2021

