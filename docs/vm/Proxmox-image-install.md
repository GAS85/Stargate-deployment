# Proxmox deployment using an image

Deploy Stargate on Proxmox

## Get the image file URL

- Please refer to [VM images list](VM-images-list.md?h=qcow2) for a list of images with URLs.
- Copy URL to clipboard, for example `https://images.hin.ch/vm-images/AlmaLinux-10.stargate-202603021402.x86_64.qcow2`

## Import the image file in Proxmox

- In Proxmox WebUI, navigate to the Storage menu and click Import
- Click Download from URL, paste the copied URL ang click "Query URL".
- Click Download and wait for "TASK OK" to appear at the end of the output log.
- Close the Task Viewer Download window.

## Create a VM

- Click "Create VM"
- Type a name for the VM
- Click "Next"
- Choose "Do not use any media"
- Click "Next"
- Click "Next"
- Click the "Thrash icon" next to "scsi0" to remove it.
- Click "Import" and under "Select Image", choose the newly imported image file.
- Click "Next"
- Select 4 CPU cores and choose your CPU Type(or use "host")
- Click "Next"
- Select 8192 MiB Memory
- Click "Next"
- Click "Next"
- Wait until the VM Create process finishes and then click on the new VM, click "Console" click "Start Now"

## Log in and initialize the stargate instance

- Log in to the VM console with the `hinadmin` user in order to configure and install the stargate components.
- To obtain the `hinadmin` password, send an email to <aroel.vandenbroele@hin.ch> with the subject: **"Password required for VM installation."**

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
