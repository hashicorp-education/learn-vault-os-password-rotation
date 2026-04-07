# Copyright IBM Corp. 2018, 2026
# SPDX-License-Identifier: MPL-2.0

set shell := ["bash", "-c"]
set positional-arguments

default: all
all: version build deploy status test clean
clean-all: clean
run: deploy

[group('docker')]
version:
   @echo ">> running $0"
   docker --version

[group('docker')]
build: clean
   @echo ">> running $0"
   docker build --tag ssh-image . 


[group('docker')]
deploy-orig:
   @echo ">> running $0"
   docker run -dit --name ssh-host -p 2222:22 ssh-image
   ssh-keyscan -t ed25519 -p 2222 localhost >> ~/.ssh/known_hosts

[group('docker')]
deploy:
   @echo ">> running $0"
   docker run -dit --name ssh-host1 -p 2221:22 ssh-image
   ssh-keyscan -t ed25519 -p 2221 localhost >> ~/.ssh/known_hosts
   docker run -dit --name ssh-host2 -p 2222:22 ssh-image
   ssh-keyscan -t ed25519 -p 2222 localhost >> ~/.ssh/known_hosts

[group('docker')]
status:
   @echo ">> running $0"
   docker ps -a -n 1 --format json | jq -r ". | {Name: .Names, State: .State, Status: .Status}"                     

[group('docker')]
test:
   @echo ">> running $0"
   docker exec -it ssh-host cat /etc/passwd | grep user-1
   echo "Testing SSH connection to localhost:2222"
   @echo "password is 'bar' for user-1"
   @ssh -q user-1@localhost -p 2222 echo "You are in!"
   

[group('docker')]
clean:
   @echo ">> running $0"
   docker stop $(docker ps -aq --filter name=ssh-host) || true
   docker rm $(docker ps -aq --filter name=ssh-host) || true
   docker image rm ssh-image || true
   pkill -f vault || true
   rm -rf vault-data/*
   rm -rf plugins/.cache
   rm -rf plugins/.runtime

