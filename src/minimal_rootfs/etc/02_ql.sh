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

[ "x$QLTYPE" == "xdebug" ] && exec setsid cttyhack sh

if [ -n "$nfsroot" ] ; then
	NFSROOT=$(echo $nfsroot|cut -d, -f 1)
	NFSOPTS=$(echo $nfsroot|cut -d, -f 2-)
	# for mount debug dir...
	echo $nfsroot| grep -q nfsvers=3 && NFSVER='nfsvers=3' || NFSVER='nfsvers=4'
	
	#echo "NFS is $nfsroot,NFSROOT is $NFSROOT, NFSOPTS is $NFSOPTS"
	mount -t nfs -o $NFSOPTS $NFSROOT /mnt || {
		echo "mount $NFSROOT failure..."
		read -n1 -s 
		reboot
	}
	
	if [ "x$QLTYPE" == "xlog" ] ; then 
		LOGROOT=${NFSROOT%/*}/debug
		mount -t nfs -o $NFSVER $LOGROOT /mnt/lonld/debug || {
		echo "mount $LOGROOT failure..."
		read -n1 -s 
		reboot
		}
		echo "mount log dir...OK"
		if [ -f /tmp/.interface ]; then
			cd /mnt/lonld/debug
			source /tmp/.interface
			rm -f qlcommlib_debug_${macaddr}.txt
			rm -f wtdll_debug_${macaddr}.txt
			touch qlcommlib_debug_${macaddr}.txt
			touch wtdll_debug_${macaddr}.txt
			echo '1' > /proc/sys/kernel/core_uses_pid 2>/dev/null
			echo "/lonld/debug/core-%e-%p-%t" > /proc/sys/kernel/core_pattern 2>/dev/null
			cd - >/dev/null
		else
			echo "no netdev information, debug init fail.."
		fi
	fi
else
	echo "(/etc/02_ql.sh) - no nfs defined..."
	read -n1 -s 
	reboot
	exit
fi
echo "mount nfs ......OK"

echo "$QLCMD" > /tmp/.qlcmd

exit

echo "(/etc/02_ql.sh) - there is a serious bug..."

# Wait until any key has been pressed.
read -n1 -s

