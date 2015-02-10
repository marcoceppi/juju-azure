# Juju on Azure made simple

The idea of this project comes from users willing to test Juju but afraid they would not have enough time and energy to learn how to install, configure and run the Juju Client.  
So how to make it easy for them? Assuming they have a cloud account, they should be able to sping a Virtual Machine. And from there, connect on a web page. Now from that page, if they be driven to create an environment with very simple instructions, the goal would be reached. 

Now it happens that Microsoft Azure exposes to its users a .publishsettings file, which contains enough information to create an environment for Juju thus bootstrap.  

There we go, with some bash-fu and MS Azure, it becomes possible to start a Juju GUI with close to 0 user interaction. 

# Starting quickly

Just connect on [Azure VM Depot](https://vmdepot.msopentech.com/Vhd/Show?vhdId=50248) and create a Virtual Machine from that image. 

# Content of this project
## Scripts

There are 3 scripts we use for this project: 

- common.sh: this contains all the variables for our deployment.
- 00-deploy.sh: this script deploys everything that's necessary on a blank Ubuntu Trusty (14.04) VM. It will
	- Make sure your user for Juju exists... By default the user should be "ubuntu". 
	- Create a pair of SSH keys for that user
	- Install a whole lot of things, including Juju
	- Install HAProxy, which we'll use to forward the Juju GUI that is spawned on another machine. Note that the GUI is a HTTPS website, therefore HAProxy 1.5+ is required. 
	- Install a web page where users can upload their Microsoft Azure .publishsettings file. 
	- Create a cronjob to wait for the Microsoft Azure .publishsettings file. The job fires every 2 minutes, and launches the last script...
- 01-bootstrap.sh: 
	- checks that the Microsoft Azure .publishsettings file has been uploaded
	- Use it to create a Juju environment for MS Azure
	- juju quickstart it
	- When it's ready, 
		- Configure HAProxy to forward this GUI
		- Updates the web page to add the password of this instance so users can connect

## Other files

The other files of the repo are configuration or other scripts that are there to support the action. 

- The content of /web contains the web site and files.
- get_cert.py is the code that can decrypt the content of the .pulishsettings file and create a valid .pem certificate to connect to the Microsoft Azure API
- haproxy is an init script that works for HAProxy 1.5.10+, which is a the minimal required version. 

# How will this be used
## Creation of the template

First of all, create a VM in Azure with the below settings: 

- Use a Ubuntu 14.04 LTS Server image
- Add a "ubuntu" user, with a standard password instead of SSH keys
- Open SSH, HTTP and HTTPS endpoints

Start the VM, connect with SSH 

    ssh ubuntu@<DNS NAME>

Now that you are on the VM, run the following commands

    sudo apt-get install git -yqq
    git clone https://github.com/SaMnCo/juju-azure
    cd juju-azure
    ./00-deploy.sh

Wait until the deployment is OK, then

     sudo waagent -deprovision

Answer "y" to the question, which will prepare the machine for templating. After that, from the Azure GUI, shutdown the VM and use **Capture** to save an image of the VM. That's it, you now have a standard VM available for you. 

## Using the template

You can now start the Easy Juju by creating VMs using this image by telling so to the Azure GUI or CLI. Browse to the HTTP page, and follow instructions. 

If you want to track the deployment, while in SSH, you can do

	sudo tail-f /var/log/syslog

You'll have a trace of the deployment that does: 

    Feb  9 17:52:01 juju19 logger: Looking for upload file /home/ubuntu/azure.publishsettings
    Feb  9 17:52:01 juju19 logger: /home/ubuntu/azure.publishsettings file found! Changing file rights... 
    Feb  9 17:52:01 juju19 logger: Now importing account into the Microsoft Azure CLI
    Feb  9 17:52:28 juju19 logger: Generating Azure Certificate
    Feb  9 17:52:28 juju19 logger: Creating specific storage account for Canonical Juju
    Feb  9 17:53:01 juju19 logger: Looking for upload file /home/ubuntu/azure.publishsettings
    Feb  9 17:53:06 juju19 logger: Identifying default subscription on Microsoft Azure
    Feb  9 17:53:09 juju19 logger: Creating Canonical Juju environment for subscription XXXXXXXXX
    Feb  9 17:53:09 juju19 logger: Bootstrapping Juju environment
	... ... ... 
    Feb  9 17:58:46 juju19 logger: Deploying Juju GUI to state server
    Feb  9 17:59:22 juju19 logger: Exposing Juju GUI
    Feb  9 17:59:24 juju19 logger: Waiting for Juju GUI to be up and running
    ... ... ... 
    Feb  9 18:00:58 juju19 logger: Waiting for Juju GUI to be up and running
    Feb  9 18:01:46 juju19 logger: Creating configuration file for HAproxy
    Feb  9 18:01:46 juju19 logger: Restarting HAProxy
    Feb  9 18:01:54 juju19 logger: Updating web page
    Feb  9 18:02:01 juju19 logger: Done! User should now enjoy Juju :)

As you can see, it takes about 10min to do the whole configuration... Be patient! 

## Pushing to VM Depot
    
Once you have a working template, you can send it to the VM Depot, which is a publicly available repository for VM images on Azure. This process has already been taken care of by us, so you don't have to do it unless you have modified the scripts. 

# Additional Notes
## Known limitations

- Under certain circumstances, creation of the storage account fails because the random name doesn't fit with MS Azure policies
- No script to delete environment and come back to initial state
- No user management. The "ubuntu" user has to be there, with the default set of keys created by the scripts. 



