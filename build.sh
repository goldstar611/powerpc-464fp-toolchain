#!/bin/bash
set -xe

version=1.27.0
maintainer_gpg_key=0x721B0FB1CDC8318AEBB888B809F6DD5F1F30EF2E

# Create a build directory and navigate into it
mkdir -p build
cd build

# Download crosstool-ng source, gpg signature, and checksum
wget -nc http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${version}.tar.bz2
wget -nc http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${version}.tar.bz2.sig
wget -nc http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${version}.tar.bz2.sha512

# Create a GPG directory, import the maintainer's GPG key, and verify the detached signature file
mkdir -p gpg
chmod 700 gpg
gpg --homedir=./gpg --keyserver keyserver.ubuntu.com --recv-keys ${maintainer_gpg_key}
gpg --homedir=./gpg --verify crosstool-ng-${version}.tar.bz2.sig

# Verify the checksum of the downloaded tarball
sha512sum -c crosstool-ng-${version}.tar.bz2.sha512

# Extract the tarball
tar -xf crosstool-ng-${version}.tar.bz2

# Navigate into the extracted directory
cd crosstool-ng-${version}

# Install necessary dependencies
# Note: The dependencies may vary based on your distribution.
#sudo apt update
#sudo install -y autoconf flex texinfo help2man gawk libtool-bin bison libncursesw5-dev

# Bootstrap, configure and build crosstool-ng
./bootstrap
./configure --enable-local
make

# Copy the configuration file into the extracted directory
cp ../../dot_config .config

# If you want to configure the toolchain, you can uncomment the next line
./ct-ng menuconfig

# Build the toolchain
./ct-ng build

echo Here is what you need to do to use the toolchain:
echo ""
echo export ARCH=powerpc
echo export CROSS_COMPILE=powerpc-464fp-linux-gnu-
echo export PATH=$PATH:$(realpath ./.build/powerpc-464fp-linux-gnu/build/)