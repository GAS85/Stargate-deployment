# Stargate VMware ESXi deployment using an image

Deploy Stargate on VMware

## Get the image file

- Download  the latest OVA(or OVF and VMDK if you prefer) image file. Please refer to [VM images list](VM-images-list.md?h=ova)

## Navigate to the ESXi web UI

- Click **Virtual Machines**
- Click **Create/Register VM**
- Choose Deploy a virtual machine from an OVF or OVA file
- Click **Next**
- Type a name for the VM
- Click **Next**
- Click to select files and choose the OVA image file (or OVF and VMDK if you prefer)
- Click **Next**
- Choose a storage to use
- Click **Next**
- Choose Network and Disk for provisioning
- Click **Next**
- Click **Finish**

## Log in and initialize the stargate instance

- Log in to the VM console with the `hinadmin` user in order to configure and install the stargate components.
- To obtain the `hinadmin` password, send an email to <aroel.vandenbroele@hin.ch> with the subject: **"Password required for VM installation."**

[Click here to send an Email](mailto:aroel.vandenbroele@hin.ch?subject=Password%20required%20for%20VM%20installation.&body=Hello%20dear%20Mr%20Vanden%20Broele,%0A%0AI%20would%20like%20to%20receive%20the%20password%20for%20a%20VM%20installation.){ .md-button style="position:relative;left:50%;transform:translate(-50%,0%);" }

```shell
sudo su -
cd ~/stargate-deployment/docker-compose/
```

- Use vi/nano to edit `customer-config.sh`
- Configuration details can be found in the [README - Step 1: Configure Customer Settings](../Docker-deploy.md#step-1-configure-customer-settings)
- Run the install script:

```shell
./scripts/install.sh
```
