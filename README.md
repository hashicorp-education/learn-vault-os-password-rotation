# README

This tutorial contains files is in support for [Automate Linux Password Rotation with HashiCorp Vault](https://developer.hashicorp.com/vault/tutorials/secrets-management/os-password-secrets#os-password-secrets) tutorials.

## Steps to test tutorial

```
PLUGIN_DIR=/path/to/plugin/directory
PLUGIN_NAME=vault-plugin-secrets-os
PLUGIN_PATH=os

# SHASUM="$(shasum -a 256 "$PLUGIN_DIR"/"$PLUGIN_NAME" | awk '{print $1}')"
# vault plugin register -sha256="$SHASUM" secret "${PLUGIN_NAME}"
vault plugin register \
   -download \
   -version="0.1.0-rc1+ent" \
   secret vault-plugin-secrets-os

vault secrets enable -path="${PLUGIN_PATH}" "${PLUGIN_NAME}"
cat > /tmp/password_policy.hcl <<-EOF
length = 20
rule "charset" {
   charset = "abcdefghijklmnopqrstuvwxyz"
min-chars = 1
}
EOF
```

## Configure hosts

```
# Create password policy named "os-policy"
vault write sys/policies/password/os-policy policy=@/tmp/password_policy.hcl
# Write the configuration
vault write -f "${PLUGIN_PATH}/config" \
   ssh_host_key_trust_on_first_use=true
vault read "${PLUGIN_PATH}/config"

HOST="test-host"
USER="test-user"

vault write "${PLUGIN_PATH}/hosts/${HOST}" \
   address=127.0.0.1 \
   port=2222
```

## Create user

```
# Create an account and configure auto rotation every minute
vault write "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}" \
   username="user-1" \
   password="bar" \
   password_policy="os-policy" \
   rotation_period="1m"
```

## Examine credentials 

```
vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}"
vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/versions"
vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/creds"
```

## Perform a rotation

```
vault write -f "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/rotate"
vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/versions"
vault read "${PLUGIN_PATH}/hosts/${HOST}/accounts/${USER}/creds"
```
