# Copyright IBM Corp. 2018, 2026
# SPDX-License-Identifier: MPL-2.0

#! /bin/bash

# start vault enterprise
# ve server -dev -dev-root-token-id root -dev-plugin-dir="plugins"

function pause(){
 read -s -n 1 -p 'Press any key to continue . . .'
 echo ''
}

source .env
PLUGIN_DIR=plugins
PLUGIN_NAME=vault-plugin-secrets-os
PLUGIN_PATH=os

# SHASUM="$(shasum -a 256 "$PLUGIN_DIR"/"$PLUGIN_NAME" | awk '{print $1}')"

# vault plugin register -sha256="$SHASUM" secret "${PLUGIN_NAME}"
vault plugin register \
   -download \
   -version="0.1.0-rc1+ent" \
   secret "${PLUGIN_NAME}"
vault secrets enable -path="${PLUGIN_PATH}" "${PLUGIN_NAME}"
cat > /tmp/password_policy.hcl <<-EOF
   length = 20
   rule "charset" {
   charset = "abcdefghijklmnopqrstuvwxyz"
   min-chars = 1
}
EOF

# Create password policy named "os-policy"
vault write sys/policies/password/os-policy policy=@/tmp/password_policy.hcl
# Write the configuration
vault write "${PLUGIN_PATH}/config" \
   ssh_host_key_trust_on_first_use=true

vault read "${PLUGIN_PATH}/config"

## Create first host with the address and port of the SSH server
for i in {1..2}; do
   HOST="ssh-host${i}"
   USER="danielle"

   echo ">> Configuring ${HOST} and ${USER}"   
   pause

   vault write "${PLUGIN_PATH}/hosts/${HOST}" \
      address=127.0.0.1 \
      port="222${i}"

   # Create an account and configure auto rotation every minute
   vault write "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}" \
      username="${USER}" \
      password="bar" \
      password_policy="os-policy" \
      rotation_period="1m"

   vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}"
   vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/versions"
   vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/creds"

   # Perform a rotation
   # vault write "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/rotate"
   # vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/versions"
   # vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/creds"

done