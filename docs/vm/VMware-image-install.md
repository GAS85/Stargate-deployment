# Stargate VMware ESXi deployment using an image

Deploy Stargate on VMware

## Get the image file

- Download  the latest OVA(or OVF and VMDK if you prefer) image file. Please refer to [VM-images-list.md](VM-images-list.md)

## Navigate to the ESXi web UI

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

## Log in and initialize the stargate instance

- Log in to the VM console with the `hinadmin` user in order to configure and install the stargate components.
- To obtain the `hinadmin` password, send an email to <aroel.vandenbroele@hin.ch> with the subject: **"Password required for VM installation."**

```shell
sudo su -
cd stargate-deployment/docker-compose/
```

- Use vi/nano to edit `customer-config.sh`
- Configuration details can be found in the [README - Step 1: Configure Customer Settings](../Docker-deploy.md#step-1-configure-customer-settings)
- Run the install script:

```shell
./scripts/install.sh
```
