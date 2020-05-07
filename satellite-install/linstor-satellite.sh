#!/bin/bash

NOCOLOR='\033[0m'
GREEN='\033[0;32m'

#script installs the LINSTOR satellite to add an additional node for use as DRBD and Thin LVM Volumes.

echo
echo -e ${GREEN}Please provide the username, ssh port, ssh key path, and new satellite node IP.${NOCOLOR}
echo

read -p 'Host Admin Username: ' uservar
read -p 'SSH Private Key Path: ' keyvar
read -p 'SSH Port: ' portvar
read -p 'New Satellite IP: ' newsatip
read -p 'New Satellite Hostname: ' newsathost

echo
echo -e ${GREEN}Before we continue, are you sure SSH and ports 3366,3367,3370,3376,3377 are open \for LINSTOR Communications? Type y/n. ${NOCOLOR}
echo

#Yes/No Prompt to continue

read -p "Are you sure? " -n 1 -r
echo 
echo "type y or n"   # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo
echo -e ${GREEN}Install LINSTOR Satellite and Controller on new Satellite${NOCOLOR}
echo
sleep 3s
ssh -p $portvar -o StrictHostKeyChecking=no -i $keyvar $uservar@$newsatip << EOF
  sudo apt-get install linux-headers-$(uname -r)
  sudo add-apt-repository ppa:linbit/linbit-drbd9-stack -y
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt install drbd-utils drbd-dkms lvm2 -y 
  sudo dprobe drbd
  sudo echo drbd > /etc/modules-load.d/drbd.conf
  sudo DEBIAN_FRONTEND=noninteractive apt install linstor-satellite linstor-client -y
  sudo systemctl enable --now linstor-satellite
  sudo systemctl start linstor-satellite
EOF

echo
echo -e ${GREEN}Adding satellites to LINSTOR${NOCOLOR}

sudo linstor node create $newsathost $newsatip

echo
echo ""
echo -e ${GREEN}LINSTOR Satellite has been installed. You should see the new Satellite node listed below. 
echo
echo -e Sleeping 10 seconds to allow the Satellites to come online${NOCOLOR}
echo
sleep 10s
sudo linstor node list

echo
echo -e ${GREEN}If table above shows the new node marked as green and ONLINE, you are done.
echo
echo -e If any show offline or an error occurred, please review install.log \in this directory. ${NOCOLOR}
echo
echo -e ${GREEN}For more information about LINSTOR visit https://www.linbit.com/linstor${NOCOLOR}
echo