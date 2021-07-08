#!/bin/bash

# var - start

# Colored text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
OFF='\033[0m'

# var - stop

# def func - start

# def func - end

# script - start

IAM=$(id -u)
if [ $IAM -gt 0 ]
then
	echo -e "${RED}You must use sudo to run this script.${OFF}"
	echo "sudo $0"
	exit 1
fi

sudo apt install git python3-pip re2c cmake openjdk-11-jre -y

git clone https://github.com/arkime/arkime
cd arkime

./easybutton-build.sh --install

make config

cd ..

rm -rf arkime/*
rm -rf arkime/.*
rmdir arkime

mkdir -p /hunt-xs/arkime/raw

chown hunter:hunter -r /hunt-xs/arkime/

./db.pl http://password:$1@localhost:9200 init

/opt/arkime/bin/arkime_add_user.sh hunter "Admin User" pihunter --admin

## instructions @ https://arkime.com/faq#maxmind
sudo apt install geoipupdate -y
