#!/bin/bash
# This script installs a complete Juju environment on a server and gets ready to play with it! 

# Make it verbose for debug
set -ex 

# Load variables
HERE=`pwd`
. ${HERE}/common.sh

# Test we are OK
if [ "`grep ${USER} /etc/passwd | wc -l`" = "0" ]
then
    echo "${USER} does not exist on this machine. Exiting gracefully"
    exit 0
    
fi

# Adding user to sudo group
sudo usermod -G sudo ${USER}

# Generate a key-pair for the user
[ -f ${USERHOME}/.ssh/id_rsa ] || sudo -u ${USER} ssh-keygen -t rsa -b 2048 -q -N "" -f ${USERHOME}/.ssh/id_rsa

# Install requirements
sudo apt-get install -qqy git haproxy jq uuid nodejs npm build-essential incron libc6 libpcre3 adduser vim-haproxy apache2 php5

# Install the juju repo and binaries
sudo add-apt-repository -y ppa:juju/stable
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get install -qqy  juju-core juju juju-deployer juju-jitsu juju-local juju-quickstart python-jujuclient charm-tools amulet

if [ ! -d ${USERHOME}/.juju-plugins ] 
then
    sudo -u ${USER} git clone https://github.com/juju/plugins.git ${USERHOME}/.juju-plugins
    sudo -u ${USER} echo "PATH=$PATH:${USERHOME}/.juju-plugins" >> ${USERHOME}/.bash_profile
    export PATH="$PATH:${USERHOME}/.juju-plugins"
fi

export PATH="$PATH:${USERHOME}/.juju-plugins"
sudo -u ${USER} export PATH="$PATH:${USERHOME}/.juju-plugins"

echo "0 0 * * * ${USER} cd ${USERHOME}/.juju-plugins && git pull" | sudo tee /etc/cron.d/${USER}-jujuplugins
sudo service cron restart

# Install the Azure CLI tools
sudo ln -sf /usr/bin/nodejs /usr/bin/node
sudo npm install -g azure-cli json2yaml yaml2json

# Create a small script to read the Publish Settings
[ ! -f ./get_cert.py ] && cat >> ./get_cert.py << EOF
#!/usr/bin/python

from xml.dom import minidom
import sys, getopt

def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print 'get_cert.py -i <inputfile> -o <outputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'get_cert.py -i <inputfile> -o <outputfile>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg
    xmldoc = minidom.parse(inputfile)
#    itemlist = xmldoc.getElementsByTagName('PublishProfile')
    itemlist = xmldoc.getElementsByTagName('Subscription')
    certb64=itemlist[0].attributes['ManagementCertificate'].value
    # print certb64.decode("base64")
    f = open(outputfile, 'w')
    f.write(certb64.decode("base64"))
    f.close
    
if __name__ == "__main__":
   main(sys.argv[1:])
EOF

chmod +x ./get_cert.py

# Installing HAPROXY 1.5+
cd /tmp
wget -c http://www.haproxy.org/download/1.5/src/haproxy-${HAPROXY_VERSION}.tar.gz 
tar xfz haproxy-${HAPROXY_VERSION}.tar.gz
cd haproxy-${HAPROXY_VERSION}
sudo make TARGET=custom CPU=native USE_PCRE=1 USE_LIBCRYPT=1 USE_LINUX_SPLICE=1 USE_LINUX_TPROXY=1
sudo make install
cd ${HERE}
sudo mv ${HERE}/haproxy /etc/init.d/haproxy
sudo chmod +x /etc/init.d/haproxy
sudo touch /etc/default/haproxy
echo "ENABLED=1" | sudo tee /etc/default/haproxy
sudo update-rc.d haproxy defaults 

# Generate a default Juju configuration
sudo -u ${USER} juju generate-config -f

# Creating the HTML Upload Page
sudo mv ${HERE}/index.html ${HERE}/file_uploader.php /var/www/html/
[ ! -f ${UPLOAD_FOLDER} ] && sudo mkdir ${UPLOAD_FOLDER}
sudo chown -R root:www-data ${UPLOAD_FOLDER}
sudo chmod -R ug+w ${UPLOAD_FOLDER}
sudo service apache2 restart

# Adding 01-wait.sh to crontab
sudo chmod +x ${HERE}/01-wait.sh
echo "*/2 * * * * ${HERE}/01-wait.sh" | sudo tee /etc/cron.d/juju-azure
sudo chmod +x /etc/cron.d/juju-azure
sudo service cron restart




