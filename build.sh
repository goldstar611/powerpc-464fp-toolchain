#!/bin/bash
set -xe

version=2022.02.5

wget -nc https://buildroot.org/downloads/buildroot-${version}.tar.gz
wget -nc https://buildroot.org/downloads/buildroot-${version}.tar.gz.sign

gpg --keyserver keyserver.ubuntu.com --recv-keys B025BA8B59C36319
gpg --verify buildroot-${version}.tar.gz.sign

tar xf buildroot-${version}.tar.gz
mv buildroot-${version}/ toolchain/
cp mybooklive_toolchain_defconfig toolchain/configs/

(cd toolchain; make mybooklive_toolchain_defconfig)
(cd toolchain; make)

