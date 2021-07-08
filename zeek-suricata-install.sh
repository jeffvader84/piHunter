#!/bin/bash

##########################################################################
####                        install Zeek/Bro                          ####
##########################################################################

# check if root

# Colored text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
OFF='\033[0m'

IAM=$(id -u)
if [ $IAM -gt 0 ]
then
	echo -e "${RED}You must use sudo to run this script.${OFF}"
	echo "sudo $0"
	exit 1
fi


apt install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3-dev swig zlib1g-dev -y

apt install libmaxminddb-dev postfix curl git -y

mkdir -p /hunt-xs/zeek
chown hunter:hunter -R /hunt-xs/zeek

git clone --recursive https://github.com/zeek/zeek

cd zeek

echo "This next part is going to take 2+ hours.  Get comfortable..."
sudo ./configure --prefix=/hunt-xs/zeek && sudo make && sudo make install

echo "PATH=/hunt-xs/zeek/bin:$PATH" >> ~/.profile
echo "PATH=/hunt-xs/zeek/bin:$PATH" >> /root/.profile
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

############ SURICATA INSTALL ################

apt install -y python-pip python3-pip libnss3-dev liblz4-dev libnspr4-dev libcap-ng-dev git

apt install -y libpcre3 libpcre3-dbg libpcre3-dev build-essential libpcap-dev libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev make libmagic-dev libjansson-dev rustc cargo python-yaml python3-yaml liblua5.1-dev

mkdir /hunt-xs/suricata
chown hunter:hunter -R /hunt-xs/suricata

wget https://www.openinfosecfoundation.org/download/suricata-6.0.2.tar.gz
tar -xzvf suricata-6.0.2.tar.gz
rm -rf suricata-6.0.2.tar.gz
cd suricata-6.0.2/
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/hunt-xs/suricata --enable-nfqueue --enable-lua
make && sudo make install
cd suricata-update/
python setup.py build
python setup.py install
cd ..
make install-full
cd ..
rm -rf suricata-6.0.2/
rmdir suricata-6.0.2

# set HOME_NET var
cp /home/hunter/piHunter/suricata.yml.original /etc/suricata/suricata.yml

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
