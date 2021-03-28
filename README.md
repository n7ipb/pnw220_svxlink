# pnw220_svxlink
Build scripts and support files for creating a SVXLink RPi image as customized for pnw220.net

## Things to know about this project
1. It creates a full image that contains much more than just SVXLink
2. Custom SVXLink sound files created using Google TTS.
3. RAM partitions for /var/log and others to limit SD card writes
4. log rotation so you don't fill up the log partition
5. fail2ban is used to monitor login attempts and block repeat offenders.
6. nftables firewall rules are installed
7. Modified VIM rules - I hate the default settings - N7IPB


## Optional use (installed but not needed for operation)
1. Alsa Loopbacks and asound.conf for Darkice
2. Darkice so the repeater audio can be streamed to an icecast server
3. SNMP - we use SNMP to gather stats to be displayed by CACTI
4. rpi-1wire for use with DS18B20 temperature probes - TX temp,inside,outside,amplifier and more
5. I2C BMP/BME280 pressure sensor for barometric pressure
