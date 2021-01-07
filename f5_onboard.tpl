
#!/bin/bash -x

# NOTE: Startup Script is run once / initialization only (Cloud-Init behavior vs. typical re-entrant for Azure Custom Script Extension )
# For 15.1+ and above, Cloud-Init will run the script directly and can remove Azure Custom Script Extension 


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

mkdir -p /config/cloud
### write_files:
# Download or Render BIG-IP Runtime Init Config 
if ${az_key_vault_authentication}
then
   cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
---
runtime_parameters: 
  - name: USER_NAME
    type: static
    value: ${bigip_username}
  - name: ADMIN_PASS
    type: secret
    secretProvider:
      environment: azure
      type: KeyVault
      vaultUrl: https://testvault-${deployment_id}.vault.${domain}.net
      secretId: test-azure-admin-secret
  - name: ROOT_PASS
    type: secret
    secretProvider:
      type: KeyVault
      environment: azure
      vaultUrl: https://testvault-${deployment_id}.vault.${domain}.net
      secretId: test-azure-root-secret
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
extension_services:
  service_operations:
    - extensionType: do
      type: url
      value: https://raw.githubusercontent.com/F5Networks/f5-bigip-runtime-init/main/examples/declarations/do_w_admin.json
post_onboard_enabled: []

EOF

else
   cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
---
runtime_parameters: 
  - name: USER_NAME
    type: static
    value: ${bigip_username}
  - name: ADMIN_PASS
    type: static
    value: ${bigip_password}
  - name: ROOT_PASS
    type: secret
    secretProvider:
      type: KeyVault
      environment: azure
      vaultUrl: https://testvault-${deployment_id}.vault.${domain}.net
      secretId: test-azure-root-secret
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
extension_services:
  service_operations:
    - extensionType: do
      type: url
      value: https://raw.githubusercontent.com/F5Networks/f5-bigip-runtime-init/main/examples/declarations/do_w_admin.json
post_onboard_enabled: []

EOF

fi

# # Download
PACKAGE_URL='https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.1.0/dist/f5-bigip-runtime-init-1.1.0-1.gz.run'
for i in {1..30}; do
    curl -fv --retry 1 --connect-timeout 5 -L $PACKAGE_URL -o "/var/config/rest/downloads/f5-bigip-runtime-init-1.1.0-1.gz.run" && break || sleep 10
done
# Install
bash /var/config/rest/downloads/f5-bigip-runtime-init-1.1.0-1.gz.run -- '--cloud azure'
# Run
f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml
