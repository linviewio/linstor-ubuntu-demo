#!/bin/bash

NOCOLOR='\033[0m'
GREEN='\033[0;32m'

# script installs the LINSTOR and provisions detected volumes for use as DRBD and Thin LVM Volumes.

#Server Config:
#Server 1: LINSTOR Controller and LINSTOR Satellite
#Server 2: LINSTOR Satellite
#Server 3: LINSTOR Satellite

echo
echo -e ${GREEN}Please provide the username, ssh port, ssh key path, and master and satellite node IPs.${NOCOLOR}
echo

read -p 'Admin username: ' uservar
read -p 'SSH Private Key Path: ' keyvar
read -p 'SSH Port: ' portvar
read -p 'Controller/Satellite IP: ' contip
read -p 'Controller/Satellite Hostname: ' conthost
read -p 'Satellite 2 IP: ' sat2ip
read -p 'Satellite 2 Hostname: ' sat2host
read -p 'Satellite 3 IP: ' sat3ip
read -p 'Satellite 3 Hostname: ' sat3host

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
echo -e ${GREEN}Please confirm SSH and ports 3366,3367,3370,3376,3377 are open \for LINSTOR Communications? 
echo -e Answer Y/N${NOCOLOR}
echo

#Yes/No Prompt to continue

read -p "ANSWER Y/N:" -n 1 -r
echo 
echo  # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo
echo -e ${GREEN}Install LINSTOR Satellite and Controller on Satellite2${NOCOLOR}
echo
sleep 3s
ssh -p $portvar -o StrictHostKeyChecking=no -i $keyvar $uservar@$sat2ip << EOF
  apt-get install linux-headers-$(uname -r) -y
  add-apt-repository ppa:linbit/linbit-drbd9-stack -y
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt install drbd-utils drbd-dkms lvm2 -y 
  modprobe drbd
  echo drbd > /etc/modules-load.d/drbd.conf
  DEBIAN_FRONTEND=noninteractive apt install linstor-satellite linstor-client -y
  systemctl enable --now linstor-satellite
  systemctl start linstor-satellite
EOF

echo
echo -e ${GREEN}Install LINSTOR Satellite and Controller on Satellite3${NOCOLOR}
echo
sleep 3s

ssh -p $portvar -o StrictHostKeyChecking=no -i $keyvar $uservar@$sat3ip << EOF
  apt-get install linux-headers-$(uname -r) -y
  add-apt-repository ppa:linbit/linbit-drbd9-stack -y
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt install drbd-utils drbd-dkms lvm2 -y 
  modprobe drbd
  echo drbd > /etc/modules-load.d/drbd.conf
  DEBIAN_FRONTEND=noninteractive apt install linstor-satellite linstor-client -y
  systemctl enable --now linstor-satellite
  systemctl start linstor-satellite
EOF

echo
echo -e ${GREEN}Adding satellites to LINSTOR${NOCOLOR}

linstor node create $conthost $contip
linstor node create $sat2host $sat2ip
linstor node create $sat3host $sat3ip

echo
echo -e ${GREEN}LINSTOR has been installed. You should see the Satellite nodes listed below. 
echo
echo -e Sleeping 10 seconds to allow Satellites to come online${NOCOLOR}
echo
sleep 10s
linstor node list

echo
echo -e ${GREEN}If table above shows all 3 nodes marked as green and ONLINE, you are done.
echo
echo -e If any show offline or an error occurred, please review install.log \in this directory. ${NOCOLOR}
echo
echo -e ${GREEN}For more information about LINSTOR visit https://www.linbit.com/linstor${NOCOLOR}
echo