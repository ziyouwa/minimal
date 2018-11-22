#!/bin/sh

# System initialization sequence:
#
# /init
#  |
#  +--(1) /etc/01_prepare.sh
#  |
#  +--(2) /etc/02_ql.sh

echo "start init ql program..."
#get kernel boot param
for i in `cat /proc/cmdline`; do
	case $i in
		*=*)
			case $i in
				waitusb*) WAITUSB=${i#*=} ;;
				lang*) LANGUAGE=${i#*=} ;;
				kmap*) KEYMAP=${i#*=} ;;
				tz*) TZ=${i#*=} ;;
				desktop*) DESKTOP=${i#*=} ;;
				ntpserver*) NTPSERVER=${i#*=} ;;
				icons*) ICONS=${i#*=} ;;
				noicons*) NOICONS=${i#*=} ;;
				user*) USER=${i#*=} ;;
				home*) MYHOME=${i#*=} ;;
				tcvd*) TCVD=${i#*=} ;;
				opt*) MYOPT=${i#*=} ;;
				swapfile*) SWAPFILE=${i#*=} ;;
				resume*) RESUME=${i#*=} ;;
				host*) HOST=1 ;;
				tftplist* ) TFTPLIST=${i#*=} ;;
				httplist* ) HTTPLIST=${i#*=} ;;
				aoe* ) AOE=${i#*=} ;;
				nbd* ) NBD=${i#*=} ;;
				mydata* ) MYDATA=${i#*=} ;;
				pretce* ) PRETCE=${i#*=} ;;
				xvesa* ) XVESA=${i#*=} ;;
				rsyslog=* ) RSYSLOG=${i#*=}; SYSLOG=1 ;;
				blacklist* ) BLACKLIST="$BLACKLIST ${i#*=}" ;;
				iso* ) ISOFILE=${i#*=} ;;
				nfsroot=*) NFS=${i#*=} ;;
				ql=*) QLTYPE=${i#*=} ;;
				init=*) QLCMD=${i#*=} ;;
			esac
		;;
		*)
			case $i in
				nozswap) NOZSWAP=1 ;;
				nofstab) NOFSTAB=1 ;;
				nortc) NORTC=1 ;;
				syslog) SYSLOG=1 ;;
				noutc) NOUTC=1 ;;
				nodhcp) NODHCP=1 ;;
				noicons) NOICONS=1 ;;
				text) TEXT=1 ;;
				xonly) XONLY=1 ;;
				superuser) SUPERUSER=1 ;;
				noswap) NOSWAP=1 ;;
				secure) SECURE=1 ;;
				protect) PROTECT=1 ;;
				cron) CRON=1 ;;
				xsetup) XSETUP=1 ;;
				laptop) LAPTOP=1 ;;
				base) ONLYBASE=1 ;;
				showapps) SHOWAPPS=1 ;;
				norestore) NORESTORE=1 ;;
				noautologin) NOAUTOLOGIN=1 ;;
				pause) PAUSE=1 ;;
				debuginit) DEBUGINIT=1 ;;
			esac
		;;
	esac
done

[ x"$QLTYPE" == "xdebug" ] && exec setsid cttyhack sh

if [ -n "$NFS" ] ; then
	NFSROOT=$(echo $NFS|cut -d, -f 1)
	#NFSDIR=$(echo $NFS|cut -d: -f 2 |cut -d, -f 1 )
	NFSOPTS=$(echo $NFS|cut -d, -f 2-)
	#echo $NFS| grep -q nfsvers=4 && modprobe nfsv4 || modprobe nfsv3
	
	#echo "NFS is $NFS,NFSROOT is $NFSROOT, NFSOPTS is $NFSOPTS"
	#exec setsid cttyhack sh
	mount -t nfs -o $NFSOPTS $NFSROOT /mnt || {
		echo "mount nfs failure..."
		read -n1 -s 
		reboot
	}
	
	if [ x"$QLTYPE" == "xlog" ] ; then 
		LOGROOT=$(echo $NFS|cut -d, -f 1)
		LOGROOT=${LOGROOT%/*}/debug
		mount -t nfs -o nfsvers=4,rw,soft $LOGROOT /mnt/lonld/debug
		echo "mount log dir...OK"
	fi
else
	echo "(/etc/02_ql.sh) - no nfs defined..."
	read -n1 -s 
	reboot
	exit
fi
echo "mount nfs ......OK"


echo $QLCMD >/tmp/.qlcmd

exit

echo "(/etc/02_ql.sh) - there is a serious bug..."

# Wait until any key has been pressed.
read -n1 -s

