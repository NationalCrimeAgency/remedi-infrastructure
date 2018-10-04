#!/bin/sh
set -e

echo "Updating apt and patching"
sudo apt-get update
sudo apt-get upgrade -f -y --force-yes

echo "Installing software-properties-common and wget"
sudo apt-get install -y software-properties-common wget

echo "Installing Java 8"
sudo apt-get install -y openjdk-8-jdk

echo "Installing Python/Pip"
sudo apt-get install -y python3-pip
sudo pip3 install pip --upgrade

echo "Installing awscli"
sudo pip3 install awscli --upgrade