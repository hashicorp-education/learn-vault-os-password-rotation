## Copyright (c) HashiCorp, Inc.
## SPDX-License-Identifier: MPL-2.0

# Docker image for RHEL with SSH
resource "docker_image" "rhel_ssh" {
  name = "ssh-host:latest"
  build {
    context    = "../"
    dockerfile = "Dockerfile"
  }
}

# SSH Host 1 + 2
# create two docker containers running RHEL with SSH, and expose them on ports 2221 and 2222
resource "docker_container" "ssh_host" {
   count = 2
   name  = "ssh-host${count.index + 1}"
   image = docker_image.rhel_ssh.image_id

   ports {
      internal = 22
      external = 2221 + count.index
   }

}
