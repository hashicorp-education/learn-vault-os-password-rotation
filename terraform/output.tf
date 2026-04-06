## Copyright (c) HashiCorp, Inc.
## SPDX-License-Identifier: MPL-2.0

output "ssh_host1_creds_path" {
  description = "Command to read credentials for SSH Host 1"
  value       = "vault read os/hosts/ssh-host1/accounts/user-1/creds"
}

output "ssh_host2_creds_path" {
  description = "Command to read credentials for SSH Host 2"
  value       = "vault read os/hosts/ssh-host2/accounts/user-1/creds"
}

# Outputs
output "ssh_host1_port" {
  description = "SSH port for host 1"
  value       = 2221
}

output "ssh_host2_port" {
  description = "SSH port for host 2"
  value       = 2222
}