#!/bin/sh

echo "*** BUILD UDEV BEGIN ***"

SRC_DIR=$(pwd)

# Grab everything .
source $SRC_DIR/.config

# Find the number of available CPU cores.
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)

# Calculate the number of 'make' jobs to be used later.
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))

# Remember the glibc installation area.src/udev/udev-builtin-keyboard.c 
GLIBC_PREPARED=$(pwd)/work/glibc/glibc_prepared

UDEV_PREPARED="$(pwd)/work/udev/udev_installed"

cd work/udev

# Clear install file
[ -d $UDEV_PREPARED ] && rm -rf $UDEV_PREPARED

# Change to the source directory ls finds, e.g. 'udev-1.24.2'.
cd $(ls -d udev-*)

# Remove previously generated artifacts.
LIBRARY_PATH=$GLIBC_PREPARED/lib make distclean

# Config
LIBRARY_PATH=$GLIBC_PREPARED/lib  ./configure \
	--prefix=$UDEV_PREPARED \
	--exec-prefix=$UDEV_PREPARED \
	--libexecdir=$UDEV_PREPARED/lib/udev \
	--with-systemdsystemunitdir=$UDEV_PREPARED \
	--disable-gtk-doc-html \
	--disable-hwdb \
	--disable-gudev \
	--disable-introspection \
	--disable-mtd_probe \
	--disable-keymap \
	--disable-logging \
	--enable-rule_generator  #\
	CC="gcc -m32" LD="ld -m32"
	
# Compile udev with optimization for "parallel jobs" = "number of processors".
echo "Building Udev..."
LIBRARY_PATH=$GLIBC_PREPARED/lib make \
  EXTRA_CFLAGS="$CFLAGS" \
   -j $NUM_JOBS

# Create the symlinks for udev. The file 'udev.links' is used for this.
echo "Preparing install files..."
LIBRARY_PATH=$GLIBC_PREPARED/lib make  install  
cp udev/udevd $UDEV_PREPARED/sbin/

# Delete unused file and directory
cd $UDEV_PREPARED
cp -f lib/udev/rules.d/* etc/udev/rules.d/
rm -rf include share lib basic* sockets* *.socket *.service
#cd sbin
#rm -f udevadm
#ln -s ../bin/udevadm .

cd $SRC_DIR

echo "*** BUILD UDEV END ***"

