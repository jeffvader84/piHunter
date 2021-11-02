
# piHunter | Version 1.4.12 (Beta)
> Data Driven Threat Hunting on the RaspberryPi

## Utilize open source tools and turn a Raspberry Pi into a threat hunting device.

Using the instructions below you can setup a Raspberry Pi to collect full-packet captures on your network then index, normalize, and search through your data to find anamolies.  All the data and tools needed to deep dive into any irregularity or weird activity is ready to go!  A good threat hunting device has both GUI tools and multiple Living off the Land (LOL) tools.  

piHunter will optimize the RaspberryPi to run all of the following tools:

| Arkime (Moloch)  | Suricata | Zeek (Bro) | Elasticsearch | Kibana  |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| Filebeat | Winlogbeats (TBD)  | RITA  | Run-RITA-Run | tcpdump |
| tshark | prads | strings | yara | python |
| scapy | PowerShell | foremost | Nmap |


*Average system mem usage is ~6.50-6.60GB*![Screenshot from 2021-09-13 13-04-09](https://user-images.githubusercontent.com/22893767/133081292-6701d0d7-3a80-4423-863c-80bc48f6fafa.png)

**Hardware/Software list:**
1. Raspberry Pi 4B 8GB
2. Micro SD Card 64 GB (128 GB Recommended)
3. [BalenaEtcher](https://www.balena.io/etcher/)
4. [RaspberryPi OS Lite 64-Bit](https://downloads.raspberrypi.org/raspios_lite_arm64/images/)
5. Ethernet Cable (2x)
6. USB 3.0 Ethernet Adaptor
7. Switch with Port Mirroring capabilities
9. External Harddrive (1 TB or more Recommended) 

**Default Login Credentials:**
- RaspberryPi -> hunter:pihunter
- Elastic stack -> elastic:pihunter
- Arkime -> hunter:pihunter

### Initial Boot and Configuring the Pi

In order to get Raspberry Pi OS ready there are some changes we need to make:  
* After using *BalenaEtcher* to image the Micro SD Card, reconnect the SD card to your computer. Then create a blank file and name it **ssh**.  This will enable ssh on boot and we can connect to the Pi via Headless mode.
* Get your Network IP information and choose a static IP for the management ethernet interfaces for the Pi. (Please note, if only using the built in ethernet port, use eth0 for all prompts in the boot script when required to select an interface.)
* I recommend using the USB-Ethernet interface as the management interface.
* Setup port mirroring on the switch to mirror all traffic on the port you are using for the built in ethernet connection on the RaspberryPi
* Plug the External HDD (HDD) into the RaspberryPi.  
* Turn on your RaspberryPi and connect to it via SSH
* Run the following commands:
```
$ sudo apt install git vim -y
$ sudo apt update -y && sudo apt upgrade -y
$ sudo reboot
$ git clone https://github.com/jeffvader84/piHunter
$ cd piHunter
```
 * Edit suricata.yaml.original by creating or editing a HOME_NET with your Private IP range.  Hint: most home routers use a /24 CIDR range.  Ex: 192.168.1.0/24
 * Edit rita.yaml and add your network range to the list under 'InternalSubnets'
 * Now follow sets 1,2,4-6 [here](https://arkime.com/faq#maxmind): then either copy your config file over to the Pi and replace the GeoIP.conf in the Git repo or edit the GeoIP.conf in this Git repo and add your AccountID and LicenseKey. 
 * Now make the boot script executable, change to root, and run the script!
```
$ sudo chmod +x boot.sh
$ sudo su
# ./boot.sh
```
**System will reboot after boot script finishes!**

```
ssh hunter@your-static-IP
```

### Verify Install
```
$ tail -f pihunter-boot.log
```
* Watch the log and look for any errors
* If all services startup properly login to ElasticStack and Arkime
* Verify data is coming in by going to http://your-static-IP:5601 and http://your-static-IP:8005
* Start hunting!

### Screen Shots

## Elastic Stack Login [http://your-static-ip:5601]
![elastic](https://user-images.githubusercontent.com/22893767/134586340-442d4704-6e17-4e47-964c-0f03f7afd023.PNG)

## Kibana Dashboard - Zeek
![kibana](https://user-images.githubusercontent.com/22893767/134586370-148bb6c7-4021-4e5a-aa6a-63fd0f98947d.PNG)

## Arkime [http://your-static-ip:8005]
![arkime](https://user-images.githubusercontent.com/22893767/134586405-4b1b60c9-665a-4539-a1ab-478c388c8d38.PNG)

## RITA HTML Report [http://your-static-ip:8080]
## Image pending

