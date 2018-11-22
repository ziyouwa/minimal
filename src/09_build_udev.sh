#!/bin/sh

set +xe 

echo "*** BUILD UDEV BEGIN ***"

SRC_DIR=$(pwd)

# Grab everything .
source $SRC_DIR/.config

# Remember the glibc installation area.src/udev/udev-builtin-keyboard.c 

UDEV_PREPARED="$(pwd)/work/udev/udev_installed"

cd work/udev

# Clear install file
[ -d $UDEV_PREPARED ] && rm -rf $UDEV_PREPARED

# Change to the source directory ls finds, e.g. 'udev-1.24.2'.
cd $(ls -d udev-*)

for F in $(ls  $SRC_DIR/minimal_config/udev*.patch)
	do
		patch -l -p1 <$F
	done

echo "current is $(pwd)"
# Config
CC="gcc $COMPILE_OPTS" CXX="g++ $COMPILE_OPTS" ./configure \
	--with-sysdir=$SYS_ROOT \
	--prefix=/ \
	--exec-prefix=/ \
	--libexecdir=/lib/udev \
	--disable-largefile \
    --disable-logging \
	--disable-gtk-doc-html \
	--disable-manpages \
	--disable-hwdb \
	--disable-gudev \
	--disable-introspection \
	--disable-mtd_probe \
	--disable-keymap \
	--disable-logging \
	--disable-kmod \
	--disable-blkid \
	--with-gnu-ld \
	--disable-static

# Remove previously generated artifacts.
CC="gcc $COMPILE_OPTS" CXX="g++ $COMPILE_OPTS"  make clean
	
# Compile udev with optimization for "parallel jobs" = "number of processors".
echo "Building Udev..."
CC="gcc $COMPILE_OPTS" CXX="g++ $COMPILE_OPTS"  make \
  EXTRA_CFLAGS="$CFLAGS" \
   -j $NUM_JOBS

# Create the symlinks for udev. The file 'udev.links' is used for this.
echo "Preparing install files..."
CC="gcc $COMPILE_OPTS" CXX="g++ $COMPILE_OPTS"  make  install  DESTDIR=$UDEV_PREPARED
cp udev/udevd $UDEV_PREPARED/sbin/

# Delete unused file and directory
cd $UDEV_PREPARED
cp -f lib/udev/rules.d/* etc/udev/rules.d/
rm -rf include share lib usr

cd $SRC_DIR

echo "*** BUILD UDEV END ***"

