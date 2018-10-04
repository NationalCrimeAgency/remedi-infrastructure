#!/bin/bash
set -euxo pipefail

echo "Installing build tools"
sudo apt-get install -y maven

echo "Downloading tools source code"

cd /opt/build

git clone https://github.com/NationalCrimeAgency/remedi-tools.git

echo "Building tools"

cd remedi-tools
mvn clean package

echo "Installing Processor and True Caser"

sudo cp processor/target/processor-*.jar /opt/bin/processor.jar
sudo cp stanford-truecaser/target/stanford-truecaser-*.jar /opt/bin/stanford-truecaser.jar
