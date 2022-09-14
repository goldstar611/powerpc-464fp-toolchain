#!/bin/bash
set -xe

wget https://buildroot.org/downloads/buildroot-2018.02.7.tar.gz
wget https://buildroot.org/downloads/buildroot-2018.02.7.tar.gz.sign

gpg --keyserver keyserver.ubuntu.com --recv-keys B025BA8B59C36319
gpg --verify buildroot-2018.02.7.tar.gz.sign

tar xf buildroot-2018.02.7.tar.gz
mv buildroot-2018.02.7 toolchain/
cp mybooklive_toolchain_defconfig toolchain/buildroot-2018.02.7/configs/

cd toolchain/buildroot-2018.02.7
  make mybooklive_toolchain_defconfig
  make

