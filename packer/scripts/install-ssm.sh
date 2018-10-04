#!/bin/bash
set -euxo pipefail

# Ubuntu 16.04 x64 SSM Install Script

sudo mkdir /tmp/ssm

cd /tmp/ssm

sudo wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb

sudo dpkg -i amazon-ssm-agent.deb