# Copyright IBM Corp. 2018, 2026
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root"
}

provider "docker" {}
