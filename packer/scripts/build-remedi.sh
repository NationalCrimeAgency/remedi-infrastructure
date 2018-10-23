#!/bin/bash
set -euxo pipefail

echo "Installing build tools for REMEDI"

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

sudo apt-get update

sudo apt-get install -y \
  make \
  git \
  curl \
  libssl-dev

sudo apt-get install -y \
  gcc-4.9 g++-4.9 gcc-4.9-base

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 100

curl https://cmake.org/files/v3.10/cmake-3.10.3-Linux-x86_64.sh -o /tmp/curl-install.sh \
  && chmod u+x /tmp/curl-install.sh \
  && sudo mkdir /usr/bin/cmake \
  && sudo /tmp/curl-install.sh --skip-license --prefix=/usr/bin/cmake \
  && rm /tmp/curl-install.sh

export PATH=$PATH:/usr/bin/cmake/bin

echo "Downloading REMEDI source code"

sudo mkdir -p /opt/build
sudo chmod 777 /opt/build
cd /opt/build

wget https://github.com/ivan-zapreev/Distributed-Translation-Infrastructure/archive/1.8.1.tar.gz
tar -xzf 1.8.1.tar.gz
mv Distributed-Translation-Infrastructure-1.8.1 Distributed-Translation-Infrastructure
cd Distributed-Translation-Infrastructure

echo "Building REMEDI"

mkdir build
cd build

cmake -DWITH_TLS=true -DCMAKE_BUILD_TYPE=Release ..
make -j 8

echo "Installing REMEDI"
sudo mkdir -p /opt/bin /opt/conf
sudo mv /opt/build/Distributed-Translation-Infrastructure/build/bpbd-* /opt/bin