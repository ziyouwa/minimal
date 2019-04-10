#!/bin/sh

# System initialization sequence:
#
# /init
#  |
#  +--(1) /etc/01_prepare.sh (this file)
#  |
#  +--(2) /etc/02_ql.sh

#dmesg -n 1
#echo "Most kernel messages have been suppressed."
mount -t devtmpfs none /dev

mount -t proc none /proc
mount -t sysfs none /sys

mkdir -p /dev/pts
mount -t devpts none /dev/pts

mount -t tmpfs none /tmp -o mode=1777
mount -t tmpfs none /run

# Start Udev to populate /dev and handle hotplug events
#echo "Starting udev daemon for hotplug support..."
#/sbin/udevd --daemon --resolve-names=never 2>&1 >/dev/null
#/sbin/udevadm trigger --action=add 2>&1 >/dev/null &

# This waits until all devices have registered
#/sbin/udevadm settle --timeout=88 2>&1 >/dev/null &
# wait all devices have registered
#wait

echo "load device drivers..."
echo '/sbin/mdev' > /proc/sys/kernel/hotplug
/sbin/mdev -s
#coldplug modules
find /sys -name modalias -print0 |xargs -0 sort -u | tr '\n' '\0' | xargs -0 /sbin/modprobe -abq 

#init network
# echo "Init network..."
/etc/04_bootscript.sh

echo "Mounted all core filesystems. Ready to continue."

