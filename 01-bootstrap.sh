#!/bin/bash
# This script configures the environment

# Make it verbose for debug
# set -ex 

# Load variables
HERE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${HERE}/common.sh
source ${USERHOME}/.bash_profile

sudo find ${UPLOAD_FOLDER} -name "*.publishsettings" -exec mv "{}" "${AZURECREDS}" \;

if [ ! -f ${AZURECREDS} ]
then
    logger "${AZURECREDS} does not exist on this machine. Exiting gracefully"
    exit 0
fi

sudo chown ubuntu:ubuntu "${AZURECREDS}"

# Import the Azure settings
azure account import ${AZURECREDS}
logger "starting import"
# Generate the Azure Cert
./get_cert.py -i ${AZURECREDS} -o ${USERHOME}/.juju/azure.pfx
openssl pkcs12 -in ${USERHOME}/.juju/azure.pfx -out ${USERHOME}/.juju/azure.pem -nodes -passin pass:""

mv ${AZURECREDS} ${AZURECREDS}.bak

# Create a storage account
STORAGE="juju"$(tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1 | tr '[:upper:]' '[:lower:]')
azure storage account create ${STORAGE} --label ${STORAGE} --location "${DEFAULT_ZONE}" --disable-geoReplication

# ID the subscription ID to use
azure account list --json > accounts.json

SUB_ID=`jq 'map(select( .isDefault == true)) | .[].id' accounts.json | tr -d "\""`
#NAME=`jq 'map(select( .isDefault == true)) | .[].name' accounts.json | tr -d " \-_\"" | tr [:upper:] [:lower:]`
NAME="jenv"$(tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1 | tr '[:upper:]' '[:lower:]')

# Create the environment file
cat >> ${USERHOME}/.juju/environments.yaml << EOF

    ${NAME}:
        type: azure
        location: ${DEFAULT_ZONE}
        management-subscription-id: ${SUB_ID}
        management-certificate-path: ${USERHOME}/.juju/azure.pem
        storage-account-name: ${STORAGE}
        availability-sets-enabled: false

EOF

# Juju switch & bootstrap
juju switch ${NAME}
juju-quickstart --no-browser

while true; 
do
    BACKEND=$(${USERHOME}/.juju-plugins/juju-pprint | grep "juju-gui" | cut -f3 -d" ")
    [ "${BACKEND}" != "" ] && break
    sleep 30
done

# Now configuring HAProxy
echo "" | sudo tee /etc/haproxy/haproxy.cfg

sudo cat >> /tmp/haproxy.cfg << EOF
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        user haproxy
        group haproxy
        daemon

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout server 50000
        timeout client 50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

    frontend https-in
        mode tcp
        option tcplog
        bind *:443
        default_backend https-servers

    backend https-servers
        mode tcp
        # balance roundrobin
        # option httpchk GET /health_check
        option ssl-hello-chk
        server juju-gui ${BACKEND}:443 maxconn 32 check
EOF

sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg

sudo service haproxy restart
azure vm endpoint ${MYVM} 443 443

URL="https\:\/\/${MYVM}"
PASS=$(cat ${USERHOME}/.juju/environments/${NAME}.jenv | grep password | cut -f2 -d":" | cut -f2 -d" ")

sudo sed -i s/^\<\!.*/\<a\ href\=\"${URL}\"\>You\ can\ now\ login\ here\ with\ password\ \"${PASS}\"\<\\/a\>/ /var/www/html/index.html




