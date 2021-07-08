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
$ sudo mount -a
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
$ sysctl -w vm.max_map_count=600000
$ cat /proc/sys/vm/max_map_count # to verify

$ docker pull docker.elastic.co/elasticsearch/elasticsearch:7.13.1-arm64
$ docker pull docker.elastic.co/kibana/kibana:7.13.1-arm64
$ docker network create huntnet

# create mount point for storgae
$ sudo mkdir -p /hunt-xs/elastic/es-logs
$ sudo mkdir -p /hunt-xs/elastic/es-data
$ sudo mkdir -p /hunt-xs/elastic/kb-logs
$ sudo mkdir -p /hunt-xs/elastic/kb-data
$ sudo chown hunter:hunter -R /hunt-xs/elastic
$ sudo chmod 777 -R /hunt-xs/elastic

# start es container
$ docker run -d --name elasticsearch --net huntnet -p 9200:9200 -p 9300:9300 -v /hunt-xs/elastic/es-data:/usr/share/elasticsearch/data -v /hunt-xs/elastic/es-logs:/usr/share/elasticsearch/logs -e "discovery.type=single-node" -e "xpack.security.enabled=true" -e "cluster.name=piHunter" -e "node.name=piHunter.es" docker.elastic.co/elasticsearch/elasticsearch:7.13.1-arm64

# setup es passwords
$ docker exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto -b > elastic.passwd
$ cat elastic.passwd
# copy your kibana_system password and enter into command below

$ docker run -d --name kibana --net huntnet -p 5601:5601 -v /hunt-xs/elastic/kb-data:/usr/share/kibana/data -v /hunt-xs/elastic/kb-logs:/var/log -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" -e "ELASTICSEARCH_URL=http://elasticsearch:9200" -e "xpack.security.enabled=true" -e "ELASTICSEARCH_USERNAME=kibana_system" -e "ELASTICSEARCH_PASSWORD=<passwd>" -e "node.name=piHunter.kb" docker.elastic.co/kibana/kibana:7.13.1-arm64

# wait 1 - 2 minutes
$ docker stop kibana
$ docker stop elasticsearch

```

### Arkime Install

**change following in config.ini:**
```
elasticsearch=http://elastic:password@localhost:9200
pcapDir = /hunt-xs/arkime/raw
maxFileSizeG = 1
freeSpaceG = 15%
```

**Arkime install will take up to an hour**
```
$ sudo su
# chmod +x arkime-install.sh
# ./arkime-install.sh <elasticpassword>
```
*Default user and password for Arkime is hunter:pihunter*

**For Geo Location on IPs
Follow instructions @ https://arkime.com/faq#maxmind**
```
$ sudo cp /etc/GeoIP.conf /etc/GeoIP.conf.original
$ sudo mv /path/to/new/GeoIP.conf /etc/GeoIP.conf
$ sudo geoipupdate
```

### Filebeat Install and configure data flow into Filebeat

```
$ wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.13.1-arm64.deb
$ sudo apt install ./filebeat-7.13.1-arm64.deb
```
**Make the edits to the filebeat.yml.original file

```
Edit the Kibana section:
 uncomment line 151
 add the following lines below host
 username: "elastic"
 password: "password"
 
Edit the Elasticsearch Output:
 uncomment lines 185 and 186
 enter the elastic password in line 186
```
**Move updated yml file**
```
$ sudo cp filebeat.yml.original /etc/filebeat/filebeat.yml
```

**Zeek filebeat setup**
```
$ sudo filebeat modules enable zeek
$ sudo cp zeek.yml /etc/filebeat/modules.d/zeek.yml
```
  
**Suricata filebeat setup**
```
sudo filebeat modules enable suricata
sudo cp suricata.filebeat.yml /etc/filebeat/modules.d/suricata.yml
  
sudo filebeat setup
sudo filebeat -e
# CTRL+C after a the output stops
```
## Setup Cron Job to bring services up from a system reboot
```
$ sudo su
# mv pihunter-startup.sh /home/hunter
# echo "@reboot sleep 15 && /home/hunter/pihunter-startup.sh" >> /var/spool/cron/crontabs/root
# echo "*/5 * * * * /hunt-xs/zeek/bin/zeekctl cron" >> /var/spool/cron/crontabs/root
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
* Verify data is coming in
* Start hunting!
