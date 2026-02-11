# Stargate Azure deployment using an image
Deploy Stargate on Azure

## Get the image file:
- Download  the latest VHD image file from https://images.vereign.io/

## Upload the Azure VHD image file:
- Navigate to https://portal.azure.com/#home
- Click Storage accounts.
- Select the storage account to use or create a new one.
- Click Block service and then Containers.
- Select the Container to upload the file to or create a new one if you do not have a Container.
- Click Upload and choose the VHD image file.
- Make sure that the Blob type is Page Blob.

## Create the image:
- Navigate to https://portal.azure.com/#home
- Click Images.
- Click Create.
- Choose the Resource group to be used or create a new one.
- Type a Name for the image.
- Choose OS type Linux and VM generation Gen 2
- At Storage blob, click browse and select the new uploaded VHD image.
- Click Review and create.
- Click Create.

## Create a VM:
- Navigate to https://portal.azure.com/#home
- Click Virtual Machines.
- Click Create, and choose Virtual Machine from the drop-down menu.
- Choose the Resource group.
- Type a Name for the VM.
- At Image, click "See all images", click "My Images" and choose the new image that was created.
- Choose the VM size.
- Choose authentication type.
- Click Next:Disks
- Select OS disk size at least 20GiB
- Click Review + create
- Click Create

## Find the public IP address of the new VM:
- Navigate to https://portal.azure.com/#home
- Click Virtual Machines.
- Click on the new VM.
- You can see the public IP address under "Primary NIC public IP"

## Log in and initialize the stargate instance:
- Use the user that you chose during VM creation and the public IP address of the new VM:
```
 ssh user@11.22.33.44 
```
- When logged in the VM:
```
[stargate@stargate-beta ~]$ sudo su -
[root@stargate-beta ~]# cd stargate-deployment/docker-compose/
```
- Use vi/nano to edit `customer-config.sh` 
- Configuration details can be found here: https://code.vereign.com/svdh/stargate-deployment#step-1-configure-customer-settings
- Run the install script:
```
[root@stargate-beta docker-compose]# ./scripts/install.sh
```
