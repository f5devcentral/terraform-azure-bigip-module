
#!/bin/bash -x

# NOTE: Startup Script is run once / initialization only (Cloud-Init behavior vs. typical re-entrant for Azure Custom Script Extension )
# For 15.1+ and above, Cloud-Init will run the script directly and can remove Azure Custom Script Extension 

# Send output to log file and serial console
mkdir -p  /var/log/cloud /config/cloud /var/config/rest/downloads
LOG_FILE=/var/log/cloud/startup-script.log
[[ ! -f $LOG_FILE ]] && touch $LOG_FILE || { echo "Run Only Once. Exiting"; exit; }
npipe=/tmp/$$.tmp
trap "rm -f $npipe" EXIT
mknod $npipe p
tee <$npipe -a $LOG_FILE /dev/ttyS0 &
exec 1>&-
exec 1>$npipe
exec 2>&1


BIGIP_USERNAME='${bigip_username}'
BIGIP_PASSWORD='${bigip_password}'

# WAIT FOR BIG-IP SYSTEMS & API TO BE UP
curl -o /config/cloud/utils.sh -s --fail --retry 60 -m 10 -L https://raw.githubusercontent.com/F5Networks/f5-cloud-libs/develop/scripts/util.sh
. /config/cloud/utils.sh
wait_for_bigip
### CHECK IF DNS IS CONFIGURED YET, IF NOT, SLEEP
echo "CHECK THAT DNS IS READY"
nslookup github.com
if [ $? -ne 0 ]; then
  echo "DNS NOT READY, SLEEP 30 SECS"
  sleep 30
fi

# Adding bigip user and password 

user_status=`tmsh list auth user $BIGIP_USERNAME`
if [[ $user_status != "" ]]; then
   response_status=`tmsh modify auth user $BIGIP_USERNAME password $BIGIP_PASSWORD`
   echo "Response Code for setting user and password:$response_status"
fi
if [[ $user_status == "" ]]; then
   response_status=`tmsh create auth user $BIGIP_USERNAME password $BIGIP_PASSWORD partition-access add { all-partitions { role admin } }`
   echo "Response Code for setting user and password:$response_status"
fi

# Getting Management Port
dfl_mgmt_port=`tmsh list sys httpd ssl-port | grep ssl-port | sed 's/ssl-port //;s/ //g'`
echo "Management Port:$dfl_mgmt_port"

### write_files:
# Download or Render BIG-IP Runtime Init Config 
cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
runtime_parameters: []
pre_onboard_enabled:
  - name: provision_rest
    type: inline
    commands:
      - /usr/bin/setdb provision.extramb 500
      - /usr/bin/setdb restjavad.useextramb true
      - /usr/bin/setdb setup.run false
extension_packages:
    install_operations:
        - extensionType: do
          extensionVersion: 1.16.0
        - extensionType: as3
          extensionVersion: 3.23.0
        - extensionType: ts
          extensionVersion: 1.12.0
extension_services:
    service_operations: []
post_onboard_enabled: []
EOF

### runcmd:
# Download
curl https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.1.0/dist/f5-bigip-runtime-init-1.1.0-1.gz.run -o f5-bigip-runtime-init-1.1.0-1.gz.run && bash f5-bigip-runtime-init-1.1.0-1.gz.run -- '--cloud azure'

f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml
