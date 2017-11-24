#!/bin/sh


apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

apt-get update
apt-get install docker-ce

ip a

apt-get install docker-compose

apt-cache madison docker-ce

docker run hello-world

