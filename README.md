# piHunter | Version 1.0 (Beta)
> Data Driven Threat Hunting on the RaspberryPi

## Utilizes open source tools and turn a Raspberry Pi into a threat hunting device.

Using the instructions below and pre-configured config files/scripts provided, you can setup a Raspberry Pi to collect full-packet captures on your network then index, normalize, and search through your data to find anamolies.  All the data and tools needed to deep dive into any irregularity or weird activity is ready to go!  A good threat hunting device has both GUI tools and multiple Living off the Land (LOL) tools.

*Average system mem usage is 6.40GB*
<img width="813" alt="pihunter-htop" src="https://user-images.githubusercontent.com/22893767/125179553-bc08fa80-e1b4-11eb-8a2d-1b58a660de41.png">

**Hardware/Software list:**
1. Raspberry Pi 4B 8GB
2. Micro SD Card 32 GB (64 GB Recommended)
3. [BalenaEtcher](https://www.balena.io/etcher/)
4. [RaspberryPi OS Lite 64-Bit](https://downloads.raspberrypi.org/raspios_lite_arm64/images/)
5. Ethernet Cable (2x)
6. USB 3.0 Ethernet Adaptor
7. Switch with Port Mirroring capabilities
9. External Harddrive (1 TB Recommended) 


### Initial Boot and Configuring the Pi

In order to get Raspberry Pi OS ready there are some changes we need to make:  
* After using *BalenaEtcher* to image the Micro SD Card, reconnect the SD card to your computer. Then create a blank file and name it **ssh**.  This will enable ssh on boot and we can connect to the Pi via Headless mode.
* Get your Network IP information and choose a static IP for the management ethernet interfaces for the Pi. (Please note, if only using the built in ethernet port, use eth0 for all prompts in the boot script when required to select an interface.
* Setup port mirroring on the switch to mirror all traffic on the port you are using for the built in ethernet connection on the RaspberryPi
* Plug the External HDD (HDD) into the RaspberryPi.  
* Turn on your RaspberryPi and connect to it via SSH
* Next clone the Git repo
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
## ^^ edit the HOME_NET variable to match your IP space
```


*Default user and password for Arkime is hunter:pihunter*

**For Geo Location on IPs
Follow instructions @ https://arkime.com/faq#maxmind**
```
$ sudo cp /etc/GeoIP.conf /etc/GeoIP.conf.original
$ sudo mv /path/to/new/GeoIP.conf /etc/GeoIP.conf
$ sudo geoipupdate
```
*Default log output goes to hunter home folder.  To change, edit variable at top of startup script for log locaiton and name*

### Verify Install
```
$ sudo reboot
```
* Wait for piHunter to reboot
* SSH into piHunter
```
$ tail -f boot.log
```
* Watch the log and look for any errors
* If all services startup properly login to ElasticStack and Arkime
* Verify data is coming in by going to http://your-static-IP:5601 and http://your-static-IP:8005
* Start hunting!

### Winlogbeats

**COMING SOON...**

### Screen Shots

**Arkime**
<img width="1267" alt="pihunter_arkime" src="https://user-images.githubusercontent.com/22893767/125179533-79472280-e1b4-11eb-8ead-51648a94e9f1.png">


**Kibana Zeek Default Dashboard**
<img width="1280" alt="pihunter-zeek" src="https://user-images.githubusercontent.com/22893767/125179534-7fd59a00-e1b4-11eb-9c28-0d1365401387.png">


**Kibana Suricata Default Dashboard**
<img width="1280" alt="pihunter-suricata" src="https://user-images.githubusercontent.com/22893767/125179538-82d08a80-e1b4-11eb-80cf-bc3b47f43092.png">

