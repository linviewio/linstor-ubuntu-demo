#!/bin/bash
NOCOLOR='\033[0m'
RED='\033[0;31m'

echo
echo -e ${RED}WARNING: THIS WILL REMOVE DRBD and LINSTOR. THIS WILL NOT REMOVE LVM2. ARE YOU SURE YOU SURE YOU WANT TO PROCEED? ENTER Y/N. ${NOCOLOR}
echo

#Yes/No Prompt to continue

read -p "Are you sure? " -n 1 -r
echo 
echo "type y or n"   # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

sudo apt remove drbd-utils drbd-dkms linstor-controller linstor-satellite linstor-client -y
sudo apt autoremove -y
sudo rm /etc/systemd/system/linstor-controller.service
sudo rm /etc/systemd/system/linstor-satellite.service
sudo systemctl daemon-reload

echo
echo -e ${RED}REMOVAL COMPLETE. PLEASE REBOOT.${NOCOLOR}
echo
echo -e ${GREEN}For more information about LINSTOR visit https://www.linbit.com/linstor${NOCOLOR}
echo
