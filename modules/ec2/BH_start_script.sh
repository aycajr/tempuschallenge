#!/bin/bash
sudo echo "127.0.0.1 localhost localhost.localdomain" $(hostname) | sudo tee -a /etc/hosts
sudo apt update
sudo rm /var/lib/apt/lists/*
sudo rm /var/cache/apt/*.bin

VERSION-NAME=$(lsb_release -c)
y=$(echo $VERSION-NAME | awk '{print $2}')
echo $y
cd /etc/apt/sources.list.d
touch docker_test.list
echo "deb https://apt.dockerproject.org/repo ubuntu-$y main" > docker_test.list

sudo apt-get install linux-image-extra-$(uname -r)
sudo apt-get update -y
sudo apt-get install docker.io
sudo service docker start
sudo docker run hello-world


