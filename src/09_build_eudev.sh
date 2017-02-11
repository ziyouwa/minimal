#!/bin/sh

echo "*** BUILD EUDEV BEGIN ***"

SRC_DIR=$(pwd)

# Grab everything .
source $SRC_DIR/.config

# Find the number of available CPU cores.
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)

# Calculate the number of 'make' jobs to be used later.
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))

# Remember the glibc installation area.src/udev/udev-builtin-keyboard.c 
GLIBC_PREPARED=$(pwd)/work/glibc/glibc_prepared

EUDEV_PREPARED="$(pwd)/work/eudev/eudev_installed"

cd work/eudev

# Clear install file
[ -d $EUDEV_PREPARED ] && rm -rf $EUDEV_PREPARED

# Change to the source directory ls finds, e.g. 'eudev-1.24.2'.
cd $(ls -d eudev-*)

# Remove previously generated artifacts.
LIBRARY_PATH=$GLIBC_PREPARED/lib make distclean

# Config
LIBRARY_PATH=$GLIBC_PREPARED/lib  ./configure \
	--prefix=$EUDEV_PREPARED  \
	--disable-blkid \
	--disable-kmod \
	--disable-selinux \
	--disable-static  #\
	CC="gcc -m32" LD="ld -m32"
	
# Compile eudev with optimization for "parallel jobs" = "number of processors".
echo "Building Eudev..."
LIBRARY_PATH=$GLIBC_PREPARED/lib make \
  EXTRA_CFLAGS="$CFLAGS" \
   -j $NUM_JOBS

# Create the symlinks for eudev. The file 'eudev.links' is used for this.
echo "Preparing install files..."
LIBRARY_PATH=$GLIBC_PREPARED/lib make SUBDIRS=src/udev install 
LIBRARY_PATH=$GLIBC_PREPARED/lib make SUBDIRS=rules install 

# Delete unused file and directory
cd $EUDEV_PREPARED
rm -rf include share lib
cd sbin
rm -f udevadm
ln -s ../bin/udevadm .

cd $SRC_DIR

echo "*** BUILD EUDEV END ***"

