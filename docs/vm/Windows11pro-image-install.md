# Windows 11 pro deployment using an image

Deploy Stargate on Windows Pro(non-pro versions do not support Hyper-V)

## Install Hyper-V

- Click the Start button, then type "Turn Windows features on or off"
- Click on that button
- Mark Hyper-V and click "OK"
- After the installation completes, click "Restart now" and wait for Windows to boot again

## Get the image

- Download the .vhdx image file. Please refer to [VM images list](VM-images-list.md?h=vhdx)

## Import the image file and create a VM with it

- Click the "Start" button and type "Hyper-V Quick Create"
- Click on that icon
- Choose "Local installation source"
- Uncheck "This machine will run Windows"
- Click "Change installation source", navigate to the downloaded .VHDX image and click on it
- Click "Create virtual machine"
- Click "Edit settings"
- Under "Memory", choose "RAM" 8192 MB
- Under "Processor", choose "Number of virtual processors" 4
- Click "OK"
- Click "Connect"
- Click "Start"

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
