# Stargate VMware ESXi deployment using an image
Deploy Stargate on VMware

## Get the image file:
- Download  the latest OVA(or OVF and VMDK if you prefer) image file from https://images.vereign.io/

## Navigate to the ESXi web UI:
- Click Virtual Machines
- Click Create/Register VM
- Choose Deploy a virtual machine from an OVF or OVA file
- Click Next
- Type a name for the VM
- Click Next
- Click to select files and choose the OVA image file (or OVF and VMDK if you prefer)
- Click Next
- Choose a storage to use
- Click Next
- Choose Network and Disk for provisioning
- Click Next
- Click Finish

## Log in and initialize the stargate instance:
- Log in to the VM console with the hinadmin user in order to configure and install the stargate components:
```
[hinadmin@stargate ~]$ sudo su -
[root@stargate ~]# cd stargate-deployment/docker-compose/
```
- Use vi/nano to edit `customer-config.sh`
- Configuration details can be found at https://code.vereign.com/svdh/stargate-deployment#step-1-configure-customer-settings
- Run the install script:
```
[root@stargate docker-compose]# ./scripts/install.sh
```
