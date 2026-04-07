# Copyright IBM Corp. 2018, 2026
# SPDX-License-Identifier: MPL-2.0


# Enable the OS secrets plugin
resource "vault_mount" "os" {
  path        = "os"
  type        = "vault-plugin-secrets-os"
  description = "OS password rotation plugin"
}

# Configure the plugin with trust on first use
resource "vault_generic_endpoint" "os_config" {
  depends_on           = [vault_mount.os]
  path                 = "os/config"
#   ignore_absent_fields = true
#   disable_read         = true

  data_json = jsonencode({
    ssh_host_key_trust_on_first_use = true
  })
}

# Create password policy
resource "vault_password_policy" "os_policy" {
  name = "os-policy"

  policy = <<EOT
length = 20
rule "charset" {
   charset = "abcdefghijklmnopqrstuvwxyz"
   min-chars = 1
}
EOT
}

# Configure SSH Host 1 in Vault
resource "vault_generic_endpoint" "ssh_host1" {
  depends_on           = [vault_mount.os, docker_container.ssh_host]
  path                 = "os/hosts/ssh-host1"
#   ignore_absent_fields = true

  data_json = jsonencode({
    address = "127.0.0.1"
    port    = 2221
  })
}

# Configure SSH Host 2 in Vault
resource "vault_generic_endpoint" "ssh_host2" {
  depends_on           = [vault_mount.os, docker_container.ssh_host]
  path                 = "os/hosts/ssh-host2"
#   ignore_absent_fields = true

  data_json = jsonencode({
    address = "127.0.0.1"
    port    = 2222
  })
}

# Configure user-1 account on SSH Host 1
resource "vault_generic_endpoint" "ssh_host1_user" {
  depends_on           = [vault_generic_endpoint.ssh_host1, vault_password_policy.os_policy]
  path                 = "os/hosts/ssh-host1/accounts/user-1"
#   ignore_absent_fields = true

  data_json = jsonencode({
    username        = "user-1"
    password        = "bar"
    password_policy = "os-policy"
    rotation_period = "5m"
  })
}

# Configure user-1 account on SSH Host 2
resource "vault_generic_endpoint" "ssh_host2_user" {
  depends_on           = [vault_generic_endpoint.ssh_host2, vault_password_policy.os_policy]
  path                 = "os/hosts/ssh-host2/accounts/user-1"
  ignore_absent_fields = true

  data_json = jsonencode({
    username        = "user-1"
    password        = "bar"
    password_policy = "os-policy"
    rotation_period = "5m"
  })
}