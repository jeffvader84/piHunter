# piHunter | Version 1.0 (Beta)
> Data Driven Threat Hunting on the RaspberryPi

## Utilizes open source tools and turn a Raspberry Pi into a threat hunting device.

Using the instructions below and pre-configured config files/scripts provided, you can setup a Raspberry Pi to collect full-packet captures on your network then index, normalize, and search through your data to find anamolies.  All the data and tools needed to deep dive into any irregularity or weird activity is ready to go!  A good threat hunting device has both GUI tools and multiple Living off the Land (LOL) tools.

**Hardware/Software list:**
1. Raspberry Pi 4B 8GB
2. Micro SD Card 32 GB (64 GB Recommended)
3. [BalenaEtcher](https://www.balena.io/etcher/)
4. [RaspberryPi OS Lite 64-Bit](https://downloads.raspberrypi.org/raspios_lite_arm64/images/)
5. Ethernet Cable (2x)
6. USB 3.0 Ethernet Adaptor
7. Switch with Port Mirroring capabilities
8. External Harddrive (1 TB Recommended) 


### Initial Boot and Configuring the Pi

In order to get Raspberry Pi OS ready there are some changes we need to make:  
* After using *BalenaEtcher* to image the Micro SD Card, reconnect the SD card to your computer. Then create a blank file and name it **ssh**.  This will enable ssh on boot and we can connect to the Pi via Headless mode.
* Get your Network IP information and choose a static IP for both ethernet interfaces for the Pi.
* Plug the External HDD (HDD) into the RaspberryPi.  Run the following commands to configure the HDD:
```
$ lsblk
# make note of the HDD location in /dev directory
$ gdisk /dev/<device>
$ mkfs.ext4 -L piHunter-xs /dev/<device>
$ mkswap -L SWAP /dev/<device>
$ blkid
# make note of the partition ids
$ sudo vi /etc/fstab
# add the following lines to fstab
UUID=<device id> /hunt-xs ext4 defaults  0 0
UUID=<device id> swap swap
$ sudo swapon -a
$ sudo umount -a
```
* Next clone the Git repo and run the first script
* You will use the network information you gathered before here
* Use you USB-Ethernet interface for the static IP
```
$ git clong https://github.com/jeffvader84/piHunter
$ cd piHunter
$ sudo chmod +x boot.sh
$ sudo su
# ./boot.sh
```
**Reboot the system!**

**Login as the new user: hunter**

**Default username:password is hunter:pihunter (make changes if desiered)**

### Install Zeek and Suricata
```
$ sudo userdel -r pi
$ cd /home/hunter
$ git clong https://github.com/jeffvader84/piHunter
$ cd piHunter
$ vi suricata.yml.original
# ^^ edit the HOME_NET variable to match your IP space
$ sudo chmod +x zeek-suricata-install.sh
$ sudo su
# ./zeek-suricata-install.sh
```

### Docker and Elastic Stack Install
```
$ cd /home/hunter
$ sudo chmod +x docker-install.sh
$ sudo su
# ./docker-install.sh
```
**Logout then Login for hunter to get docker permissions**
```
```

### Arkime Install
