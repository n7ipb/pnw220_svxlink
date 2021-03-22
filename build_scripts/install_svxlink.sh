#!/bin/bash
# install_svxlink.sh
# Downloads and install svxlink and required support tools
#
set -e

install () {

    #
    echo "update repositories"
    sudo apt-get update
    sudo apt-get -y install libxml-simple-perl vim git python-rpi.gpio python-dev python-serial python-smbus python-jinja2 python-xmltodict python-psutil python-pip
    echo "Create svxlink user"
    sudo useradd -c "svxlink user" -G gpio,audio,video,i2c,plugdev,$USER -d /home/svxlink -m -s /sbin/nologin svxlink
    
    echo "Install development files needed to build"
    sudo apt-get -y install dnsutils cmake libsigc++-2.0-dev libjsoncpp1 libjsoncpp-dev libasound2-dev libpopt-dev libgcrypt-dev tk-dev libgsm1-dev libspeex-dev libopus-dev groff libcurl4-openssl-dev doxygen rtl-sdr librtlsdr-dev libogg-dev tcl-expect
    # 
    echo "Install additional files needed for full operation"
    sudo apt-get -y install vim nftables libjsoncpp1 libjsoncpp-dev bc snmpd fail2ban python3-pip darkice
    #
    echo "Configure groups for snmp"
    #"Add Debian-snmp to video and i2c groups so temperature and voltage scripts can be accessed by SNMP"
    sudo usermod -a -G i2c Debian-snmp
    sudo usermod -a -G video Debian-snmp
    echo "Download svxlink sources"
    cd ~/Projects
    git clone https://github.com/sm0svx/svxlink.git
    echo "Configure and build"
    cd ~/Projects/svxlink
    cd src
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DUSE_OSS=NO -DUSE_QT=NO -DWITH_SYSTEMD=YES ..
    echo "Building"
    make -j4
    echo "Making Documents"
    make doc
    echo "Installing"
    sudo make install
    sudo ldconfig
    # 
    # Download Custom sound and logic files for PNW220.net system
    # 
    #
    cd ~/Projects
    echo "Download rpi-1wire programs and place in Projects directory"
    echo "You don't have to use them but this makes them available"
    echo "If you do install 1-wire temperature probes"
    echo "Follow the directions in Projects/rpi-1wire"
    git clone https://github.com/n7ipb/rpi-1wire
    #
    sleep 5
    echo "go to the directory where custom config files are found"
    echo "This directory would have been created and copied to "
    echo "/home/svx_admin/Projects by the prep_user script"
   #
   echo "Fetch latest sound files"
   echo "default = us_female"
   read -p "us_male, us_female or other: " SOUNDFILE
   echo
   SOUNDFILE=${SOUNDFILE:-us_female}
   cd /usr/share/svxlink/sounds
   sudo wget -q https://github.com/n7ipb/svxlink_sounds/raw/master/$SOUNDFILE.bz2 
   echo $SOUNDFILE
   sudo tar jxf $SOUNDFILE.bz2
   echo "Create link to sound files"
   sudo ln -fs $SOUNDFILE en_US
   echo "SvxLink and sounds installed"
   echo "removing sound archive"
   sudo rm $SOUNDFILE.bz2
   sleep 5
   #
   cd ~/Projects/pnw220_svxlink
   echo "Installing modified systemd svxlink.service"
   echo "This version handles the ram disk we use for logging"
   sudo cp systemd_system/* /lib/systemd/system
   #
   echo "installing custom logic files in /usr/share/svxlink/events.d/local"
   #
   cd ~/Projects/pnw220_svxlink
   sudo cp -a svxlink_local /usr/share/svxlink/events.d/local
   #
   echo "Installing custom svxlink.conf file and gpio.conf"
   sudo cp -a pnw220_etc/svxlink/* /etc/svxlink/
   #
   echo "SVXLink is now configured with the default settings for PNW220 repeaters"
   echo "Next we'll create some of the support directories and copy over files" 
   echo "that are used for temperature reporting and voltage measurement"
   sleep 5
   sudo cp svxlink_local_bin/* /usr/local/bin
   echo "Temp data direcory and files"
   sudo mkdir /var/tmp/svxlink
   sudo cp -a svxlink_var/* /var/tmp/svxlink
   echo "Install crontab"
   sudo cp svxlink_cron/* /etc/cron.d
   echo "Install adafruit circuitpython bme280 support"
   sudo pip3 install adafruit-circuitpython-bme280
   echo "Populate the svx_admin directory and Project area"
   sudo cp -a svx_admin_home/* /home/svx_admin
   sudo cp -a svx_admin_home/.ssh /home/svx_admin/.ssh
   sudo cp -a svx_admin_home/.bash_git /home/svx_admin
   sudo cp -a svx_admin_home/.bash_aliases /home/svx_admin
   echo "Installl vimrc.local - I don't like the stock settings"
   sudo cp pnw220_etc/vim/vimrc.local /etc/vim
   sudo cp pnw220_etc/vim/vimrc /etc/vim
   echo "install snmpd configuration with extended commands"
   sudo cp pnw220_etc/snmp/snmpd.conf /etc/snmp/snmpd.conf
   echo "Enable snmp on next reboot"
   sudo systemctl enable snmpd
   echo "Install logrotate file for svxlink"
   sudo cp pnw220_etc/logrotate.d/svxlink /etc/logrotate.d/svxlink
   echo "install fail2ban configuration"
   sudo cp pnw220_etc/fail2ban/jail.local /etc/fail2ban
   echo "Install nft firewall rules and enable"
   sudo cp pnw220_etc/nftables.conf /etc
   echo "Enable firewall on next reboot"
   sudo systemctl enable nftables.service
   echo "install darkice configuration"
   sudo cp pnw220_etc/darkice.cfg /etc
   echo "install alsa asound.conf"
   sudo cp pnw220_etc/asound.conf /etc
   echo "create loopback devices for alsa"
   sudo cp pnw220_etc/modprobe.d/alsa.conf /etc/modprobe.d
   echo "Enable loopback on boot"
   echo "snd_aloop" | sudo tee -a /etc/modules
   echo 
   echo "Create a udev rule for hidraw devices that allows svxlink access"
   echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", MODE=\"0664\", GROUP=\"plugdev\"" | sudo tee -a /lib/udev/rules.d/99-hidraw.rules
   echo done
}
# Do not run if user 'pi'
# 
#    
if [ "$USER" == "pi" ]; then
   echo "Running as user 'pi' Please run pnw220_init to create another user, reboot and login as "
   echo "the new user.   Then run this script"
   echo "aborting execution"
   exit
fi

echo "Do you wish to install SvxLink for PNW220?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install; break;;
        No ) break;;
    esac
done

sleep 5

echo "The system will now reboot"

sleep 5
echo "Install complete, rebooting."
sudo reboot
