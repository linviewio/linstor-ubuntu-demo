#!/bin/bash

NOCOLOR='\033[0m'
GREEN='\033[0;32m'

# script installs the LINSTOR and provisions detected volumes for use as DRBD and Thin LVM Volumes.

#Server Config:
#Server 1: LINSTOR Controller and LINSTOR Satellite

echo
echo -e ${GREEN}Please provide the username, ssh port, ssh key path, and master and satellite node IPs.${NOCOLOR}
echo

read -p 'Controller/Satellite IP: ' contip
read -p 'Controller/Satellite Hostname: ' conthost

echo
echo -e ${GREEN}Now installing DRBD and LINSTOR on Satellites${NOCOLOR}
echo

echo -e ${GREEN}Installing Linux Headers${NOCOLOR}
echo
sleep 3s
apt-get install linux-headers-$(uname -r) -y

echo
echo -e ${GREEN}Adding LINSTOR PPA${NOCOLOR}
echo
sleep 3s
DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:linbit/linbit-drbd9-stack -y
apt-get update

echo
echo -e ${GREEN}Installing DRBD9 and LVM2${NOCOLOR}
echo

sleep 3s
DEBIAN_FRONTEND=noninteractive apt install drbd-utils drbd-dkms lvm2 -y
modprobe drbd

echo
echo -e ${GREEN}Set DRBD to run at startup${NOCOLOR}
echo
sleep 3s
echo drbd > /etc/modules-load.d/drbd.conf

echo
echo -e ${GREEN}Install LINSTOR Satellite and Controller on master node${NOCOLOR}
echo
sleep 3s
apt install linstor-controller linstor-satellite  linstor-client -y
systemctl enable --now linstor-controller
systemctl start linstor-controller

echo
echo -e ${GREEN}Adding satellite to LINSTOR${NOCOLOR}

linstor node create $conthost $contip


echo
echo -e ${GREEN}LINSTOR has been installed. You should see the Satellite nodes listed below. 
echo
echo -e Sleeping 10 seconds to allow Satellites to come online${NOCOLOR}
echo
sleep 10s
linstor node list

echo
echo -e ${GREEN}If table above shows all 1 node marked as green and ONLINE, you are done.
echo
echo -e If any show offline or an error occurred, please review install.log \in this directory. ${NOCOLOR}
echo
echo -e ${GREEN}For more information about LINSTOR visit https://www.linbit.com/linstor${NOCOLOR}
echo