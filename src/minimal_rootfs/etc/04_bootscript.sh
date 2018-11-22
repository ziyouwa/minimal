#!/bin/sh

# System initialization sequence:
#
# /init
#  |
#  +--(1) /etc/01_prepare.sh
#  |
#  +--(2) /etc/02_ql.sh

#echo -e "Welcome to \\e[1mMinimal \\e[32mLinux \\e[31mLive\\e[0m (/sbin/init)"

TRY=15

for C in $(seq 1 $TRY) ;do
	[ $(ls /sys/class/net 2>/dev/null|grep -v lo |wc -l) -gt 0 ] && break
  echo "Waiting network initalizing...($C/$TRY)"
  sleep 2s
done
if [ $C -gt $TRY ] ;then
	echo -e "\\e[31m!!!Ethernet not found!!!\\e[0m Press any key to continue."
	read -n1 -s
else
	for DEVICE in /sys/class/net/* ; do
		echo "Found network device ${DEVICE##*/}" 
		ip link set ${DEVICE##*/} up 
		[ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -t 6 -s /etc/05_rc.dhcp 
		[ $? -eq 0 ] && echo "Network device ${DEVICE##*/} initializated." && break
	done
fi

