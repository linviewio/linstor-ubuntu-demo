# LINSTOR Basic Install on Ubuntu

**WARNING** This is a demo installation script and does not deploy an enterprise grade solution. Please only use this for evaluation purposes.

## About LINSTOR
Block Storage Management For Containers. With native integration to Kubernetes, LINSTOR makes building, running, and controlling block storage simple. LINSTOR® is open-source software designed to manage block storage devices for large Linux server clusters. It’s used to provide persistent Linux block storage for Kubernetes, OpenStack, OpenNebula, and OpenShift environments. 

## Repo Description
These scripts perform a basic LINSTOR installation with the following components across 3 or more nodes:

* LVM2
* DRBD
* LINSTOR Controller (1 node)
* LINSTOR Satellite (3 nodes initially. More can be added with the satellite instll script.)

## Requirements

* Ubuntu 16.04 or 18.04 LTS (tested)
* 3 nodes (more can be added using the satellite installer)
* Ports 3366,3367,3370,3376,3377 open between nodes for LINSTOR communications
* 
* SSH with key between controller and satellite nodes
* The following information:
  * admin user with no password `sudo` or root user
  * ssh key to access satellites and path to key
  * ssh port
  * controller IP and hostname
  * satellite 2 and 3 IP and hostnames

## Additional LINSTOR Install Information

- Install Documentation: https://www.linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-installtion
- Storage Pool Creation: https://www.linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-storage_pools
- Resource Group Creation: https://www.linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-linstor-resource-groups
- Resource Creation: https://www.linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-linstor-new-volume

## Installation Instructions

### Installing a LINSTOR 3 node setup (1 controller/satellite node, 2 satellite nodes)
* Clone this repo
* `cd` into the repo directory
* `sudo chmod +x install.sh`
* `sudo ./install.sh`
* Provide the details when prompted
* Review `install.log` if there are any errors

### Installing an additional LINSTOR satellite
* Clone this repo to the new satellite node
* `cd` into the repo directory
* `sudo chmod +x /satellite-install/linstor-satellite.sh`
* `sudo ./install-satellite.sh`
* Provide the details when prompted
* Review `satellite.log` if there are any errors
* On the LINSTOR controller node, run `linstor node create %newsatellitehostname% %newsatelliteip%`
* On the controller, run `linstor node list` to confirm you see the new satellite


### Removal Instructions

**IMPORTANT: THIS WILL REMOVE LINSTOR AND DRBD. THIS IS DESTRUCTIVE AND WILL LIKELY CAUSE DATA LOSS. THIS DOES _NOT_ REMOVE LVM2.**

* Clone this repo to each node where you want to remove, or copy ./remove/remove-linstor.sh to each machine.
* Run `./remove-linstor.sh`
* Reboot when done

## Using Linstor

Please read the user-guide provided at [docs.linbit.com](https://docs.linbit.com).