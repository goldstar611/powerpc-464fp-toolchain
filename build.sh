#!/bin/bash
set -xe

ctng_version=1.27.0
gpg_keyserver=keyserver.ubuntu.com

declare -A gpg_keys_to_import
gpg_keys_to_import["ctng"]="0x721B0FB1CDC8318AEBB888B809F6DD5F1F30EF2E"
gpg_keys_to_import["linux"]="0x647F28654894E3BD457199BE38DBBDC86092693E"
gpg_keys_to_import["zlib"]="0x5ED46A6721D365587791E2AA783FCD8E58BCAFBA"
gpg_keys_to_import["zstd"]="0x4EF4AC63455FC9F4545D9B7DEF8FE99528B52FFD"
gpg_keys_to_import["gmp"]="0x343C2FF0FBEE5EC2EDBEF399F3599FF828C67298"
gpg_keys_to_import["mpfr"]="0xA534BE3F83E241D918280AEB5831D11A0D4DB02A"
gpg_keys_to_import["mpc"]="0xAD17A21EF8AED8F1CC02DBD9F7D5C9BF765C61E3"
gpg_keys_to_import["ncurses"]="0x19882D92DDA4C400C22C0D56CC2AF4472167BE03"
# reminder to check libiconv later
gpg_keys_to_import["libiconv"]="0x68D94D8AAEEAD48AE7DC5B904F494A942E4616C2"
gpg_keys_to_import["gettext"]="0x9001B85AF9E1B83DF1BDA942F5BE8B267C6A406D"
gpg_keys_to_import["binutils"]="0x3A24BC1E8FB409FA9F14371813FCEF89DD9E3C4F"
gpg_keys_to_import["glibc"]="0xFD19E6D31B192EE4DC63EAD3DC2B16215ED5412A"




# Create a build directory and navigate into it
mkdir -p build
cd build

# Create a GPG directory and set the GNUPGHOME environment variable
# export GNUPGHOME so that crosstool-ng can find the GPG keys
mkdir -p gpg
chmod 700 gpg
export GNUPGHOME=$(realpath ./gpg)
for package_key in ${gpg_keys_to_import[@]}; do
    gpg --keyserver ${gpg_keyserver} --recv-keys ${package_key}
done

# Download crosstool-ng source, gpg signature, and checksum
wget -nc http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${ctng_version}.tar.bz2
wget -nc http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${ctng_version}.tar.bz2.sig
wget -nc http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${ctng_version}.tar.bz2.sha512

# Verify the GPG key for crosstool-ng
gpg --verify crosstool-ng-${ctng_version}.tar.bz2.sig

# Verify the checksum of the downloaded tarball
sha512sum -c crosstool-ng-${ctng_version}.tar.bz2.sha512

# Extract the tarball
tar -xf crosstool-ng-${ctng_version}.tar.bz2

# Navigate into the extracted directory
cd crosstool-ng-${ctng_version}

# Install necessary dependencies
# Note: The dependencies may vary based on your distribution.
#sudo apt update
#sudo install -y autoconf flex texinfo help2man gawk libtool-bin bison libncursesw5-dev

# Bootstrap and configure crosstool-ng
if [ -f .ctng-is-configured ]; then
    echo "crosstool-ng is already configured. Skipping..."
else
    ./bootstrap
    ./configure --enable-local
    make
    touch .ctng-is-configured
fi

# Build and "install" crosstool-ng The Hackers Way
if [ -f .ctng-is-built ]; then
    echo "crosstool-ng is already built. Skipping..."
else
    # Copy the configuration file into the extracted directory
    cp ../../dot_config .config

    # If you want to configure the toolchain, you can uncomment the next line
    #./ct-ng menuconfig

    # Create a directory for the toolchain sources
    mkdir -p src

    # Build the toolchain
    ./ct-ng build
    touch .ctng-is-built
fi

set +x

echo Here is what you need to do to use the toolchain:
echo ""
echo export ARCH=powerpc
echo export CROSS_COMPILE=powerpc-464fp-linux-gnu-
echo export PATH=$PATH:$(realpath ~/x-tools/powerpc-464fp-linux-gnu/bin)
