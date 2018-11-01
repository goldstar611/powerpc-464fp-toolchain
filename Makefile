.PHONY: mbl_toolchain clean

buildroot-2018.02.7.tar.gz:
	wget https://buildroot.org/downloads/buildroot-2018.02.7.tar.gz
	wget https://buildroot.org/downloads/buildroot-2018.02.7.tar.gz.sign

tarball_verified: buildroot-2018.02.7.tar.gz
	gpg --keyserver keyserver.ubuntu.com --recv-keys 59C36319
	gpg --verify buildroot-2018.02.7.tar.gz.sign
	touch tarball_verified

toolchain/buildroot-2018.02.7: tarball_verified
	tar xvf buildroot-2018.02.7.tar.gz
	mv buildroot-2018.02.7 toolchain/
	cp mybooklive_toolchain_defconfig toolchain/buildroot-2018.02.7/configs/

toolchain/buildroot-2018.02.7/.config:
	cd toolchain/buildroot-2018.02.7 && $(MAKE) mybooklive_toolchain_defconfig

mbl_toolchain: toolchain/buildroot-2018.02.7 toolchain/buildroot-2018.02.7/.config
	cd toolchain/buildroot-2018.02.7 && $(MAKE)

clean:
	rm buildroot-2018.02.7.tar.gz.sign   || true
	rm buildroot-2018.02.7.tar.gz        || true
	rm -rf toolchain/buildroot-2018.02.7 || true

