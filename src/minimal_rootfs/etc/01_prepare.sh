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
mount -t tmpfs none /tmp -o mode=1777
mount -t tmpfs none /run

mkdir -p /dev/pts

mount -t devpts none /dev/pts

# Start Udev to populate /dev and handle hotplug events
echo -n "Starting udev daemon for hotplug support..."
/sbin/udevd --daemon --resolve-names=never 2>&1 >/dev/null
/sbin/udevadm trigger --action=add 2>&1 >/dev/null &

# This waits until all devices have registered
/sbin/udevadm settle --timeout=88 &
# wait all devices have registered
wait

#init network
/etc/04_bootscript.sh

echo "Mounted all core filesystems. Ready to continue."

