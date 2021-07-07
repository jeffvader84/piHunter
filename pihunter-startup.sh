#!/bin/bash

# var - start

ZEEK='/hunt-xs/zeek/bin/zeekctl'
SURICATA='suricata'
ARKIMECAP='arkimecapture'
ARKIMEVIEW='arkimeviewer'
FILEBEAT='filebeat'
KBNAME='kibana'
ESNAME='elasticsearch'
LOGDIR='/home/hunter/pihunter-boot.log'

# var - stop

# def func - start

# func to start service using systemd and check exit status // if exit ne 0, stop script and note in log
sysdStart() {
     echo "`date` $1 - starting..." >> $LOGDIR
     systemctl start $1
     sleep $2
     systemctl is-active --quiet $1
     if [ $? = 0 ]; then
          echo "`date` $1 - ready" >> $LOGDIR
	  sleep 3
     else
          echo "`date` $1 - FAILED to start" >> $LOGDIR
          return 1
     fi
}

# func to start docker containers and check exit status
dockerStart() {
     echo "`date` $1 - starting..." >> $LOGDIR
     docker start $1
     if [ $? = 0 ]; then
	     sleep $2
	     if [ "$(docker container inspect -f '{{.State.Running}}' $1)" == "true" ]; then
		     echo "`date` $1 - ready" >> $LOGDIR
		     sleep 3
	     else
		     echo "`date` $1 - FAILED to start" >> $LOGDIR
		     return 1
	     fi
     else
	     return 1
     fi
}

# func to start services using binary and check exit status
cmdStart() {
     echo "`date` $1 - starting..." >> $LOGDIR
     $1 start
     sleep $2
     $1 status | grep running 1>/dev/null
     if [ $? = 0 ]; then
	     echo "`date` $1 - ready" >> $LOGDIR
	     sleep 3
     else
	     echo "`date` $1 - FAILED to start" >> $LOGDIR
	     return 1
     fi
}

# def func - stop

# script - start

echo "`date` piHunter services starting... standby..." >> $LOGDIR

# start zeek
cmdStart $ZEEK 10

# start suricata
sysdStart $SURICATA 10

# start elasticsearch
dockerStart $ESNAME 120

# start arkime
sysdStart $ARKIMECAP 30
sysdStart $ARKIMEVIEW 15

# start filebeat
sysdStart $FILEBEAT 15

# start kibana
dockerStart $KBNAME 60

echo "`date` piHunter services are up and ready to HUNT!" >> $LOGDIR
echo "============================ ===========================================" >> $LOGDIR

# script - stop
