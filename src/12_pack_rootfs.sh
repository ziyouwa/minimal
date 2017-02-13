#!/bin/sh

echo "*** PACK ROOTFS BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

cd work

echo "Packing initramfs. This may take a while..."

# Remove the old 'initramfs' archive if it exists.
rm -f rootfs.cpio.gz

cd rootfs

# Packs the current 'initramfs' folder structure in 'cpio.xz' archive.
find . | cpio -R root:root -H newc -o | $INITRD_COMPRESS_CMD > ../rootfs.cpio.xz

echo "Packing of initramfs has finished."

cd $SRC_DIR

echo "*** PACK ROOTFS END ***"

