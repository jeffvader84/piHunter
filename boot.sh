#!/bin/bash

# var - start

# Colored text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
OFF='\033[0m'

WHOAMI=`id -u`
LOGDIR='/home/hunter/pihunter-install.log'
EPASSWD='pihunter'

# var - stop

# def func - start

# func for printing start of new task in a specific color

# func to add start of task to log
logStart() {
  echo "[`date`] $1 - Started Install/Configuration" >> $LOGDIR
}

# func to check for errors on tasks and output information to log file
logEnd() {
  if [ $? = 0 ]; 
  then
	  echo "[`date`] $1 - completed successfully" >> $LOGDIR
  else
          echo "[`date`] $1 - FAILED to complete" >> $LOGDIR
          return 1
  fi
}

# ascii art
asciiArt() {
	echo '      ___                       ___           ___           ___           ___           ___           ___     '
	echo '     /\  \          ___        /\__\         /\__\         /\__\         /\  \         /\  \         /\  \    '
	echo '    /::\  \        /\  \      /:/  /        /:/  /        /::|  |        \:\  \       /::\  \       /::\  \   '
	echo '   /:/\:\  \       \:\  \    /:/__/        /:/  /        /:|:|  |         \:\  \     /:/\:\  \     /:/\:\  \  '
	echo '  /::\~\:\  \      /::\__\  /::\  \ ___   /:/  /  ___   /:/|:|  |__       /::\  \   /::\~\:\  \   /::\~\:\  \ '
	echo ' /:/\:\ \:\__\  __/:/\/__/ /:/\:\  /\__\ /:/__/  /\__\ /:/ |:| /\__\     /:/\:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\'
	echo ' \/__\:\/:/  / /\/:/  /    \/__\:\/:/  / \:\  \ /:/  / \/__|:|/:/  /    /:/  \/__/ \:\~\:\ \/__/ \/_|::\/:/  /'
	echo '      \::/  /  \::/__/          \::/  /   \:\  /:/  /      |:/:/  /    /:/  /       \:\ \:\__\      |:|::/  / '
	echo '       \/__/    \:\__\          /:/  /     \:\/:/  /       |::/  /     \/__/         \:\ \/__/      |:|\/__/  '
	echo '                 \/__/         /:/  /       \::/  /        /:/  /                     \:\__\        |:|  |    '
	echo '                               \/__/         \/__/         \/__/                       \/__/         \|__|    '

}

# def func - end

# script - start

echo -e "\n\n\n"
asciiArt
echo -e "\n\n\n"
sleep 2

if [ $WHOAMI -gt 0 ]; then
	echo -e "${RED}You must use sudo to run this script.${OFF}"
	echo "sudo $0"
	exit 1
fi

echo -e "Do you want to use the deafult password?"
read -p "[y/n]: " ANS
case $ANS in
	y | Y | yes | YES | Yes)
		echo "Selected default password: $EPASSWD"
		;;
	n | N | no | NO | No)
		read -p "Enter new password: " EPASSWD
		echo -e "New password is: $EPASSWD"
		;;
	*)
		echo -e "Incorrect selection.  Exiting boot script."
		exit 1
		;;
esac

# creat user hunter
useradd -m hunter
if [ $? = 0 ];
then
	echo "New user - hunter - created"
	echo "[`date`] piHunter install log - Started" > $LOGDIR
else
	echo "Failed to create user"
	exit 1
fi

echo -e "$EPASSWD\n$EPASSWD\n" | passwd hunter
usermod -aG adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi hunter
sleep 2

# add ascii Art to hunter login
echo -e "\n" >> /home/hunter/.profile
echo "# ascii Art piHunter on login" >> /home/hunter/.profile
echo "echo ''" >> /home/hunter/.profile
echo "echo ''" >> /home/hunter/.profile
echo "echo ''" >> /home/hunter/.profile
echo "echo '      ___                       ___           ___           ___           ___           ___           ___     '" >> /home/hunter/.profile
echo "echo '     /\  \          ___        /\__\         /\__\         /\__\         /\  \         /\  \         /\  \    '" >> /home/hunter/.profile
echo "echo '    /::\  \        /\  \      /:/  /        /:/  /        /::|  |        \:\  \       /::\  \       /::\  \   '" >> /home/hunter/.profile
echo "echo '   /:/\:\  \       \:\  \    /:/__/        /:/  /        /:|:|  |         \:\  \     /:/\:\  \     /:/\:\  \  '" >> /home/hunter/.profile
echo "echo '  /::\~\:\  \      /::\__\  /::\  \ ___   /:/  /  ___   /:/|:|  |__       /::\  \   /::\~\:\  \   /::\~\:\  \ '" >> /home/hunter/.profile
echo "echo ' /:/\:\ \:\__\  __/:/\/__/ /:/\:\  /\__\ /:/__/  /\__\ /:/ |:| /\__\     /:/\:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\'" >> /home/hunter/.profile
echo "echo ' \/__\:\/:/  / /\/:/  /    \/__\:\/:/  / \:\  \ /:/  / \/__|:|/:/  /    /:/  \/__/ \:\~\:\ \/__/ \/_|::\/:/  /'" >> /home/hunter/.profile
echo "echo '      \::/  /  \::/__/          \::/  /   \:\  /:/  /      |:/:/  /    /:/  /       \:\ \:\__\      |:|::/  / '" >> /home/hunter/.profile
echo "echo '       \/__/    \:\__\          /:/  /     \:\/:/  /       |::/  /     \/__/         \:\ \/__/      |:|\/__/  '" >> /home/hunter/.profile
echo "echo '                 \/__/         /:/  /       \::/  /        /:/  /                     \:\__\        |:|  |    '" >> /home/hunter/.profile
echo "echo '                               \/__/         \/__/         \/__/                       \/__/         \|__|    '" >> /home/hunter/.profile
echo "echo ''" >> /home/hunter/.profile
echo "echo ''" >> /home/hunter/.profile
echo "echo ''" >> /home/hunter/.profile
echo -e "\n" >> /home/hunter/.profile

# add conditional to delete user pi
echo "# conditional to delete user pi after piHunter install" >> /home/hunter/.profile
echo 'if [[ -n `cat /etc/passwd | grep pi` ]]' >> /home/hunter/.profile
echo 'then' >> /home/hunter/.profile
echo '	sudo userdel -r pi' >> /home/hunter/.profile
echo 'else' >> /home/hunter/.profile
echo '	echo "user pi already deleted" > /dev/null' >> /home/hunter/.profile
echo 'fi' >> /home/hunter/.profile

# set variable for external storage setup
echo -e "Review the list of all storage connected to your RaspberryPi\n"
lsblk
read -p 'Enter the external storage device name from the above list (i.e. if there is sda and sda1, enter sda): ' XS

# change into new user home dir for rest of script
cd /home/hunter
logEnd "Changed into hunter's home dir"
echo "# Generated by piHunter" > pihunter.passwd
echo "" >> pihunter.passwd
echo "RaspberryPi   ->  hunter:$EPASSWD" >> pihunter.passwd
echo "Elastic Stack ->  hunter:$EPASSWD" >> pihunter.passwd
echo "Arkime        ->  hunter:$EPASSWD" >> pihunter.passwd
echo "" >> pihunter.passwd
echo " END OF FILE " >> pihunter.passwd

# assign static IP
logStart "Assigning Static IP"
read -p 'Enter the hostname for this RaspberryPi: ' HNAME
read -p 'Enter an static IP address: ' HIP
read -p 'Enter a DNS server address: ' HDNS
read -p 'Enter the router IP: ' ROUTERIP
echo "[!] Select an interface from the following list:"
ifconfig | grep -E 'eth[0-9]' | cut -d : -f 1
sleep 1
read -p 'Select a management interface from list above [ if using a USB ethernet adaptor, this is the recommended interface ]: ' INTERFACE
read -p 'Select a monitor interface from list above [ built in ethernet interface is recommended ]: ' MONINTERFACE
echo ""

# update pi / install required packages
logStart "Begin updates and package dependencies installation"
apt update -y
apt install htop gdisk whois dnsutils tmux vim git prads tcpdump net-tools scapy nmap tshark foremost yara '^libssl1.0.[0-9]$' libunwind8 network-manager -y && sudo apt upgrade -y
logEnd "Updates and package dependencies installation"

echo "##########################################################################"
echo "####                         install Docker                           ####"
echo "##########################################################################"
logStart "Docker"
# get install script
curl -fsSL https://get.docker.com -o get-docker.sh
# install
sh get-docker.sh
logEnd "Docker"
logStart "Docker configure/test"
# add hunter to docker group to run commands without sudo
usermod -aG docker hunter
# test docker
docker run --name hello-world hello-world
sleep 5
docker stop hello-world
docker container rm hello-world
rm -rf /home/hunter/get-docker.sh
logEnd "Docker configure/test"


echo "##########################################################################"
echo "####                       configure System                           ####"
echo "##########################################################################"

# Disable auto-run daemons from recent installs
systemctl stop prads
systemctl disable prads

# Optimize RaspberryPiOS
logStart "Begin system optimization"
# Disable HW at boot
echo "" >> /boot/config.txt
echo "# Disable WiFi" >> /boot/config.txt
echo "dtoverlay=disable-wifi" >> /boot/config.txt
echo "# Disable Bluetooth" >> /boot/config.txt
echo "dtoverlay=disable-bt" >> /boot/config.txt
echo "# Disable HDMI" >> /boot/config.txt
echo "hdmi_blanking=2" >> /boot/config.txt

# Disable Audio
echo "blacklist snd_bcm2835" > /etc/modprobe.d/alsa-blacklist.conf
systemctl stop alsa-state.service
systemctl stop alsa-restore.service
systemctl disable alsa-restore.service
systemctl disable alsa-state.service
systemctl mask alsa-state.service
systemctl mask alsa-restore.service

# Disable Bluetooth
systemctl stop bluetooth.service
systemctl disable bluetooth.service
systemctl mask bluetooth.service
systemctl stop bluetooth.target
systemctl disable bluetooth.target
systemctl mask bluetooth.target

# Disable wpasupplicant
systemctl stop wpa_supplicant
systemctl disable wpa_supplicant
#systemctl mask wpa_supplicant

# Disable Randmon number generator process
systemctl disable rng-tools.service
systemctl stop rng-tools.service

logStart "System configuration"
# Set Hostname
hostnamectl set-hostname $HNAME
echo "127.0.0.1       localhost" > /etc/hosts
echo "::1	     localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1        ip6-allnodes" >> /etc/hosts
echo "ff02::02       ip6-allrouters" >> /etc/hosts
echo "" >> /etc/hosts
#echo "127.0.0.1                  $HNAME" >> /etc/hosts
echo "127.0.1.1                 $HNAME" >> /etc/hosts

# Set Static IP,Router,DNS // Disable ipv6

logStart "Network specs"

# sudo vi /etc/resolv.conf

echo "# Generated by piHunter" > /etc/resolv.conf
echo "domain home" >> /etc/resolve.conf
echo "nameserver $HDNS" >> /etc/resolv.conf

# set static IPs
echo "interface $INTERFACE" >> /etc/dhcpcd.conf
echo "static ip_address=$HIP/24" >> /etc/dhcpcd.conf
echo "static routers=$ROUTERIP" >> /etc/dhcpcd.conf
echo "static domain_name_servers=$HDNS" >> /etc/dhcpcd.conf

# setup monitor interface
echo -e "\n" >> /etc/dhcpcd.conf
echo "# setup monitor interface" >> /etc/dhcpcd.conf
echo "denyinterfaces eth0" >> /etc/dhcpcd.conf
echo -e "\n" >> /etc/network/interfaces 
echo "# setup monitor interface" >> /etc/network/interfaces
echo "auto $MONINTERFACE" >> /etc/network/interfaces
echo "iface $MONINTERFACE inet manual" >> /etc/network/interfaces
echo " up ifconfig $MONINTERFACE 0.0.0.0 up" >> /etc/network/interfaces
echo " up ip link set $MONINTERFACE promisc on" >> /etc/network/interfaces
echo " down ip link set $MONINTERFACE promisc off" >> /etc/network/interfaces
echo " down ip link set $MONINTERFACE down" >> /etc/network/interfaces

# disable ipv6
echo "net.ipv6.conf.$INTERFACE.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.$MONINTERFACE.disable_ipv6 = 1" >> /etc/sysctl.conf

# edit network/interfaces file
echo "" >> /etc/network/interfaces
echo "auto $INTERFACE" >> /etc/network/interfaces
echo "iface $INTERFACE inet manual" >> /etc/network/interfaces
echo " address $HIP/24" >> /etc/network/interfaces
echo " gateway $ROUTERIP" >> /etc/network/interfaces

# disable WiFi
echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf

# external storage setup
logStart "Mount point directory and External Storage setup"
# delete any existing partition, then format the disk
echo -e "d\nd\nd\nn\n\r\n\r\n\r\n8300\nw\nY" | sudo gdisk /dev/$XS
# create label for partition
echo -e "y" | sudo mkfs.ext4 -L piHunter-xs /dev/${XS}1
# grab UUID
XSUUID=$(blkid | grep ${XS}1 | awk '{print $3}')
# add to fstab for persistence on reboot
echo "$XSUUID /hunt-xs ext4 defaults  0 0" >> /etc/fstab
# make dir for mount point
mkdir /hunt-xs
# mount external storage
mount -a
logEnd "Mount point directory and External Storage setup"

# Download and extract PowerShell
logStart "PowerShell"
# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-linux-arm64.tar.gz

# Make folder to put powershell
mkdir /usr/bin/powershell

# Unpack the tar.gz file
tar -xzvf ./powershell-7.1.3-linux-arm64.tar.gz -C /usr/bin/powershell
logEnd "PowerShell"

# remove pwsh install file
rm -rf powershell-7.1.3-linux-arm64.tar.gz


echo "##########################################################################"
echo "####                        install Zeek/Bro                          ####"
echo "##########################################################################"
logStart "Zeek"
apt install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3-dev swig zlib1g-dev libmaxminddb-dev postfix curl git -y

mkdir -p /hunt-xs/zeek
chown hunter:hunter -R /hunt-xs/zeek

git clone --recursive https://github.com/zeek/zeek

cd zeek

echo "This next part is going to take 2+ hours.  Get comfortable..."
sudo ./configure --prefix=/hunt-xs/zeek && sudo make && sudo make install
logEnd "Zeek build from source"

echo "PATH=/hunt-xs/zeek/bin:/usr/local/go/bin:/usr/bin/powershell:$PATH" >> /home/hunter/.profile
echo "PATH=/hunt-xs/zeek/bin:/usr/local/go/bin:/usr/bin/powershell:$PATH" >> /root/.profile
echo "alias zeekctl='/hunt-xs/zeek/bin/zeekctl'" >> /root/.bashrc

source /home/hunter/.profile
source /root/.profile

echo "172.16.30.0/24    Home Network" > /hunt-xs/zeek/etc/networks.cfg

chown hunter:hunter -R /hunt-xs/zeek

# configure Zeek to output JSON
echo "@load policy/tuning/json-logs.zeek" >> /hunt-xs/zeek/share/zeek/site/local.zeek

# start zeek
/hunt-xs/zeek/bin/zeekctl install
/hunt-xs/zeek/bin/zeekctl cron enable
echo ""
echo ""

cd ..
rm -rf zeek/*
rm -rf zeek/.*
rmdir zeek

# create cronjob
#echo "@reboot sleep 15 && /hunt-xs/zeek/bin/zeekctl start" >> /var/spool/cron/crontabs/root
echo "*/5 * * * * /hunt-xs/zeek/bin/zeekctl cron" >> /var/spool/cron/crontabs/root
logEnd "Zeek install"
echo "##########################################################################"
echo "####                        install Suricata                          ####"
echo "##########################################################################"
logStart "Suricata"
apt install -y python-pip python3-pip libnss3-dev liblz4-dev libnspr4-dev libcap-ng-dev git libpcre3 libpcre3-dbg libpcre3-dev build-essential libpcap-dev libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev make libmagic-dev libjansson-dev rustc cargo python-yaml python3-yaml liblua5.1-dev

mkdir /hunt-xs/suricata

wget https://www.openinfosecfoundation.org/download/suricata-6.0.2.tar.gz
tar -xzvf suricata-6.0.2.tar.gz
rm -rf suricata-6.0.2.tar.gz
cd suricata-6.0.2/
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/hunt-xs/suricata --enable-nfqueue --enable-lua
#make && sudo make install
make && make install
logEnd "Suricata build from source"
cd suricata-update/
python setup.py build
python setup.py install
cd ..
make install-full
logEnd "Suricata setup"
cd ..
rm -rf suricata-6.0.2/
rmdir suricata-6.0.2

# set HOME_NET var
cp /home/pi/piHunter/suricata.yml.original /etc/suricata/suricata.yml

# change ring buffer size
echo "Edit /etc/suricata/suricata.yaml file # Avoid Packet Loss"
echo "Increase the Ring Buffer Size to 30000"
sed -i "s/#ring-size: 2048/ring-size: 30000/" /etc/suricata/suricata.yaml

# Update Suricata Rules
suricata-update

chown hunter:hunter -R /hunt-xs/suricata

# create service systemd unit file
touch /etc/systemd/system/suricata.service

echo "[Unit]" >> /etc/systemd/system/suricata.service
echo "Description=Suricata Intrusion Detection Service" >> /etc/systemd/system/suricata.service
echo "After=network.target syslog.target" >> /etc/systemd/system/suricata.service
echo "" >> /etc/systemd/system/suricata.service
echo "[Service]" >> /etc/systemd/system/suricata.service
echo "ExecStart=/usr/bin/suricata -c /etc/suricata/suricata.yaml -i eth0 -S /hunt-xs/suricata/lib/suricata/rules/suricata.rules" >> /etc/systemd/system/suricata.service
echo "ExecReload=/bin/kill -HUP $MAINPID" >> /etc/systemd/system/suricata.service
echo "ExecStop=/bin/kill $MAINPID" >> /etc/systemd/system/suricata.service
echo "" >> /etc/systemd/system/suricata.service
echo "[Install]" >> /etc/systemd/system/suricata.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/suricata.service

# Logrotate
echo "/var/log/suricata/*.log /var/log/suricata/*.json" >> /etc/logrotate.d/suricata
echo "{" >> /etc/logrotate.d/suricata
echo "    daily" >> /etc/logrotate.d/suricata
echo "    maxsize 10G" >> /etc/logrotate.d/suricata
echo "    rotate 10" >> /etc/logrotate.d/suricata
echo "    missingok" >> /etc/logrotate.d/suricata
echo "    nocompress" >> /etc/logrotate.d/suricata
echo "    create" >> /etc/logrotate.d/suricata
echo "    sharedscripts" >> /etc/logrotate.d/suricata
echo "    postrotate" >> /etc/logrotate.d/suricata
echo "    systemctl restart suricata.service" >> /etc/logrotate.d/suricata
echo "    endscript" >> /etc/logrotate.d/suricata
echo "}" >> /etc/logrotate.d/suricata

# setup cron job update
echo "37 1 * * * sudo suricata-update –disable-conf=/etc/suricata/disable.conf && sudo systemctl restart suricata.service" >> /var/spool/cron/crontabs/hunter

ldconfig /lib
logEnd "Suricata install"
echo "##########################################################################"
echo "####                      install Elastic Stack                       ####"
echo "##########################################################################"
logStart "Elastic Stack"
sysctl -w vm.max_map_count=600000
if [[ `cat /proc/sys/vm/max_map_count` = 600000 ]]
then
	echo "Successfully changed vm.max_map_count"
else
	echo "Failed to change vm.max_map_count"
fi

# get elastic stack docker images
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.13.1-arm64
docker pull docker.elastic.co/kibana/kibana:7.13.1-arm64

# setup docker network
docker network create huntnet

# create mount point for storgae
mkdir -p /hunt-xs/elastic/es-logs
mkdir -p /hunt-xs/elastic/es-data
mkdir -p /hunt-xs/elastic/kb-logs
mkdir -p /hunt-xs/elastic/kb-data
chown hunter:hunter -R /hunt-xs/elastic
chmod 777 -R /hunt-xs/elastic

docker run -d --name elasticsearch --net huntnet -p 9200:9200 -p 9300:9300 -v /hunt-xs/elastic/es-data:/usr/share/elasticsearch/data -v /hunt-xs/elastic/es-logs:/usr/share/elasticsearch/logs -e "discovery.type=single-node" -e "xpack.security.enabled=true" -e ELASTIC_PASSWORD=$EPASSWD -e "cluster.name=piHunter" -e "node.name=piHunter.es" docker.elastic.co/elasticsearch/elasticsearch:7.13.1-arm64
# sleep to allow elasticsearch container to spin up
sleep 120

docker run -d --name kibana --net huntnet -p 5601:5601 -v /hunt-xs/elastic/kb-data:/usr/share/kibana/data -v /hunt-xs/elastic/kb-logs:/var/log -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" -e "ELASTICSEARCH_URL=http://elasticsearch:9200" -e "xpack.security.enabled=true" -e "ELASTICSEARCH_USERNAME=elastic" -e "ELASTICSEARCH_PASSWORD=$EPASSWD" -e "node.name=piHunter.kb" docker.elastic.co/kibana/kibana:7.13.1-arm64
# sleep to allow kibana container to spin up
sleep 90

#docker stop kibana
logEnd "Elastic Stack"
echo "##########################################################################"
echo "####                          install Arkime                          ####"
echo "##########################################################################"
logStart "Arkime"
sudo apt install git python3-pip re2c cmake openjdk-11-jre -y

git clone https://github.com/arkime/arkime
cd arkime

./easybutton-build.sh --install

echo -e "$MONINTERFACE\nno\nhttp://localhost:9200\npihunter\nyes" | make config
logEnd "Arkime build from source"

mkdir -p /hunt-xs/arkime/raw
# create Arkime dir and change permissions
chown hunter:hunter -R /hunt-xs/arkime/
chmod 777 -R /hunt-xs/arkime
# copy custom config file
cp /home/pi/piHunter/config.ini.original /opt/arkime/etc/config.ini
# initiate Arkime
cd db
./db.pl http://elastic:pihunter@localhost:9200 init
# create default admin user
/opt/arkime/bin/arkime_add_user.sh hunter "Admin User" $EPASSWD --admin

# Setup IP Geo Location service
## instructions @ https://arkime.com/faq#maxmind
sudo apt install geoipupdate -y
cp /etc/GeoIP.conf /etc/GeoIP.conf.original
mv /home/pi/piHunter/GeoIP.conf /etc/GeoIP.conf
geoipupdate

# remove Git repo for Arkime
cd /home/hunter
rm -rf arkime/*
rm -rf arkime/.* 2>/dev/null
rmdir arkime

logEnd "Arkime"
echo "##########################################################################"
echo "####                         install Filebeat                         ####"
echo "##########################################################################"
logStart "Filebeat"
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.13.1-arm64.deb
apt install ./filebeat-7.13.1-arm64.deb
rm -rf filebeat-7.13.1-arm64.deb
logEnd "Filebeat"

logStart "Filebeat config and data ingestion"
cp /home/pi/piHunter/filebeat.yml.original /etc/filebeat/filebeat.yml

# Zeek filebeat setup
filebeat modules enable zeek
cp /home/pi/piHunter/zeek.yml /etc/filebeat/modules.d/zeek.yml

# Suricata filebeat setup
filebeat modules enable suricata
cp /home/pi/piHunter/suricata.filebeat.yml /etc/filebeat/modules.d/suricata.yml

# Finish Filebeat Setup
filebeat setup
sleep 30
logEnd "Filebeat config and data ingestion"

echo "##########################################################################"
echo "####                           install RITA                           ####"
echo "##########################################################################"

logStart "RITA install"
mkdir /hunt-xs/rita
chown -R hunter:hunter /hunt-xs/rita/
docker pull mongo:4.0.27-rc0
docker pull nginx
docker run -d --name mongodb --network huntnet -p 27017:27017 -v /hunt-xs/rita:/data/db  mongo:4.2-rc
mkdir /home/hunter/rita-html-report
echo '<b>Hello, this is the default page installed by piHunter.  After you have rita data in your MongoDB, use run-rita-run -r to generate an HTML report.</b>' > /home/hunter/rita-html-report/index.html
docker run -d --name rita-web -p 8080:80 -v /home/hunter/rita-html-report:/usr/share/nginx/html nginx

# install Go Language
wget https://golang.org/dl/go1.14.linux-arm64.tar.gz
sudo tar -C /usr/local -xvzf go1.14.linux-arm64.tar.gz
rm -rf /home/hunter/go1.14.linux-arm64.tar.gz
# added /usr/local/go/bin to $PATH for both hunter and ROOT during Zeek install
# clone RITA repo
git clone https://github.com/activecm/rita.git
cd rita
make && make install
# create config directory
mkdir /etc/rita && chmod 755 /etc/rita
mkdir -p /var/lib/rita/logs && chmod -R 755 /var/lib/rita
# copy RITA config file into /etc/rita
cp /home/pi/piHunter/rita.yaml /etc/rita/config.yaml && chmod 666 /etc/rita/config.yaml
cd /home/hunter
rm -rf /home/hunter/rita/*
rm -rf /home/hunter/rita/.* 2>/dev/null
rmdir /home/hunter/rita
# python -m SimpleHTTPServer 8080 > /dev/null 2>&1 &
logEnd "RITA install"
logStart "Run-RITA-Run install"
# install Run-RITA-Run
git clone https://github.com/jeffvader84/run-rita-run
cd run-rita-run
chmod +x run-rita-run.sh
cp run-rita-run.sh /usr/local/bin/run-rita-run
cd ..
rm -rf run-rita-run/*
rm -rf run-rita-run/.* 2>/dev/null
rmdir run-rita-run
logEnd "Run-RITA-Run"

echo "##########################################################################"
echo "####                       configure Persistence                      ####"
echo "##########################################################################"

# Setup Cron Job to bring services up from a system reboot
logStart "Setup Cron Job to startup services from system boot"
chmod +x /home/pi/piHunter/pihunter-startup.sh
mv /home/pi/piHunter/pihunter-startup.sh /home/hunter
chown hunter:hunter /home/hunter/pihunter-startup.sh
echo "@reboot sleep 10 && /home/hunter/pihunter-startup.sh" >> /var/spool/cron/crontabs/root
echo "5 0 * * * run-rita-run -ir" >> /var/spool/cron/crontab/root
echo "10 0 * * * run-rita-run -i" >> /var/spool/cron/crontab/root
sudo chmod -R 600 /var/spool/cron/crontabs/root
sudo chmod -R 600 /var/spool/cron/crontabs/hunter
logEnd "Setup Cron Job to startup services from system boot"

echo "[!] reboot the system, login as user hunter and run the following command"
#echo "[!] sudo userdel -r pi"

reboot
# script - stop
