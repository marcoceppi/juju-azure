# Juju on Azure made simple

The idea of this project comes from users willing to test Juju but afraid they would not have enough time and energy to learn how to install, configure and run the Juju Client.  
So how to make it easy for them? Assuming they have a cloud account, they should be able to sping a Virtual Machine. And from there, connect on a web page. Now from that page, if they be driven to create an environment with very simple instructions, the goal would be reached. 

Now it happens that Microsoft Azure exposes to its users a .publishsettings file, which contains enough information to create an environment for Juju thus bootstrap.  

There we go, with some bash-fu and MS Azure, it becomes possible to start a Juju GUI with close to 0 user interaction. 

# Content of this project
## Scripts

There are 3 scripts we use for this project: 

- common.sh: this contains all the variables for our deployment.
- 00-deploy.sh: this script deploys everything that's necessary on a blank Ubuntu Trusty (14.04) VM. It will
	- Make sure your user for Juju exists...
	- Create a pair of SSH keys for that user
	- Install a whole lot of things, including Juju
	- Install HAProxy, which we'll use to forward the Juju GUI that is spawned on another machine
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

# How will this be used

TBD
