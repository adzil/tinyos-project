#!/bin/bash

## Configure bash script
set -e
export DEBIAN_FRONTEND=noninteractive

## Update repository
echo ">>> Updating repository..."
apt-get update
## Install dependencies (GCC 4.9 required as GCC >= 5 are not supported)
echo ">>> Installing required dependencies..."
apt-get install -y build-essential gcc-4.9 g++-4.9 python python-dev \
    nescc tinyos-tools
## Configure to use gcc-4.9 instead of gcc-5
echo ">>> Configuring GCC to use version 4.9..."
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-4.9 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-4.9 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-4.9 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-4.9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 10 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-5 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-5 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-5 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-5 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-5

## Clone release repository in /usr/src
echo ">>> Cloning tinyos-release git repository..."
git clone --depth 1 https://github.com/tinyos/tinyos-release.git /usr/src/tinyos-2.x
## Update environment variable config in /etc/profile.d/tinyos.sh
echo ">>> Updating environment variables configuration for tinyos..."
cat > /etc/profile.d/tinyos.sh <<'END'
export TOSROOT=/usr/src/tinyos-2.x
export TOSDIR=$TOSROOT/tos
export CLASSPATH=$CLASSPATH:$TOSROOT/support/sdk/java/tinyos.jar
export MAKERULES=$TOSROOT/support/make/Makerules
export PYTHONPATH=$TOSROOT/support/sdk/python:$PYTHONPATH
END
source /etc/profile.d/tinyos.sh
## Fix python incorrect versioning in $TOSROOT/support/make/sim.extra
echo ">>> Patching tinyos source..."
sed -i "s/^PYTHON_VERSION.*/PYTHON_VERSION ?= \$(shell python --version 2>\&1 | sed 's\/Python 2\\\.\\\([0-9]\\\)\\\.[0-9]\\\+\/2.\\\1\/')/" \
    $TOSROOT/support/make/sim.extra

## Set default directory to /vagrant
echo ">>> Setting default start dir to /vagrant..."
echo "cd /vagrant" >> /home/ubuntu/.bashrc

echo ">>> You are ready to go :)"
