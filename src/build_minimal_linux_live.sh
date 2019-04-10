#!/bin/sh

SRC_DIR=$(pwd)

# Grab everything from config file
source $SRC_DIR/.config

# Download all the packages need to download together
time sh 00_clean.sh
time sh 01_get_kernel.sh &
time sh 03_get_glibc.sh &
time sh 06_get_busybox.sh &
time sh 08_get_udev.sh &
#time sh 08_get_eudev.sh &
time sh 13_get_syslinux.sh &

# Waiting download complete.
wait

time sh 02_build_kernel.sh

if [ "$BUILD_GLIBC" = "true" ] ; then
	time sh 04_build_glibc.sh || exit 1
	time sh 05_prepare_glibc.sh 
	#time sh 09_build_eudev.sh
fi
time sh 07_build_busybox.sh || exit 1

if [ "$UDEV_ENABLE" = "true" ] ; then
	time sh 09_build_udev.sh || exit 1
wait

#time sh 10_prepare_src.sh 
time sh 11_generate_rootfs.sh || exit 1
time sh 12_pack_rootfs.sh || exit 1
#[ -n "$CUSTOM_CONFIG" ] && time sh 14_generate_iso.sh
#[ -n "$DEPLOY_SCRIPT" ] && time sh $DEPLOY_SCRIPT
