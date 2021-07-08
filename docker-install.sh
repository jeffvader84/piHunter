#!/bin/bash

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

# get install script
curl -fsSL https://get.docker.com -o get-docker.sh
# install
sh get-docker.sh
# add hunter to docker group to run commands without sudo
usermod -aG docker hunter
# test docker
docker run --name hello-world hello-world
sleep 5
docker stop hello-world
docker container rm hello-world
