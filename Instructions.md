# Instructions

Instructions for using crude scripts to use to create an image.
This file is new and the exact sequence has not been tested.
The scripts have been but are not robust and assume everything works.

Lots more work needs to be done to the scripts but what is here
works for now


******************************************
## Create a clean OS image

Download the latest raspberry pi OS from https://www.raspberrypi.org/software/operating-systems/

Raspberry Pi OS Lite is recommended

### Copy the image to an SD card - 
I use SanDisk 32GB High Endurance Video MicroSDHC cards, https://www.amazon.com/gp/product/B07P14QHB7

I suggest downloading the official Raspberry Pi imager for your operating system
https://www.raspberrypi.org/blog/raspberry-pi-imager-imaging-utility/

It's available for Windows, macOS and Ubuntu.  Source is also available and I found it easy to 
build and install on OpenSUSE.

### Run rpi-imager

#### rpi-imager Advanced options

- Press ‘Ctrl-Shift-X’
- Set the hostname,
- Enable SSH 
- Set a password for the 'pi' user
- Best NOT to set Allow public-key authentication only
    We need to be able to log in to a newly created user with a password to install svxlink
- Configure wifi if you wish
- Set locale settings

#### Choose the OS

- Select the OS - Raspberry Pi OS (other)
- Select Raspberry Pi OS Lite (32-bit)
- Select 'Storage'
- Identify your SD card and select it
- Click on 'WRITE' and wait for it to finish.
- Exit rpi-imager

You are now ready to boot the new image.

### Boot the RPi with the new image.

- Login as user pi
- Get the prep_user.sh script

    wget -q https://github.com/n7ipb/pnw220_svxlink/raw/master/build_scripts/prep_user.sh

- Execute prep_user.sh
    bash ./prep_user.sh

prep_user.sh updates the OS packages, installs additonal packages for later use and
runs raspi-config where you will have the opportunity to enable any needed 
interfaces (SPI,I2C,1-Wire)
Do NOT let raspi-config reboot.  The prep_user script will do that for you.
Once raspi-config is complete it will create a new user (svx_admin by default) for administration 
work amd disable user 'pi' for security.  
Most attempts to hack a pi start with attempted logins as user 'pi'.

- The pi will then reboot..

## Installing svxlink and support packages as svx_admin

- Log back in as the new user (svx_admin@newhostname)

- This is a good point to install ssh public keys. (Highly, highly recommended)
On linux this is the 'ssh-copy-id user@hostname' command executed from the machine that
has the public/private keys.

- Move to the Projects directory
    cd ~/Projects
- Download the pnw_220_svxlink project from github.
    git clone https://github.com/n7ipb/pnw220_svxlink.git

### Run the install script

- Move to the build_scripts directory
    cd ~/Projects/pnw220_svxlink/build_scripts
- start the script
    ./install_svxlink.sh'

This will update the repostiories, install needed support packages, create a svxlink user (no login created)
 and add the user 'svxlink' to various groups.

It will then pull the latest svxlink source, configure and build it.

Then it installs the binaries, man pages, default sound files and custom svxlink .tcl files.

Next support directories, crontab entries, updated vim.local, firewall rules, fail2ban, logrotate files, snmpd.conf
and enable loopback devices for the sound system.

Then it reboots

## Log in and configure

- Edit /etc/svxlink/svxlink.conf (In the future this will be done thru a configuration program)
    Make all changes needed for your system

- Enable svxlink with 'sudo systemctl enable svxlink' svxlink will automatically start on the next reboot
- Manually start and stop with 'sudo systemctl start/stop/restart svxlink'


