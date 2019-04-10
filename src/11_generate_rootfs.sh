#!/bin/sh

# set -xe

echo "*** GENERATE ROOTFS BEGIN ***"

SRC_DIR=$(pwd)
LIBDIR=lib

#Grab everything from config file
source $SRC_DIR/.config

# Remember the glibc prepared folder.
GLIBC_PREPARED=$(pwd)/work/glibc/glibc_prepared

# Remember the BusyBox install folder.
BUSYBOX_INSTALLED=$(pwd)/work/busybox/busybox_installed

# Remember the Udev install folder.
UDEV_INSTALLED=$(pwd)/work/udev/udev_installed
#EUDEV_INSTALLED=$(pwd)/work/eudev/eudev_installed

KERNEL_INSTALLED=$(pwd)/work/kernel/kernel_installed

cd work

echo "Preparing initramfs work area..."
rm -rf rootfs

# Copy all BusyBox generated stuff to the location of our 'initramfs' folder.
cp -r $BUSYBOX_INSTALLED rootfs || exit 1

# Copy all rootfs resources to the location of our 'initramfs' folder.
cp -r $SRC_DIR/minimal_rootfs/* rootfs

cd rootfs

# Remove 'linuxrc' which is used when we boot in 'RAM disk' mode. 
rm -f linuxrc

if [ "$COPY_SOURCE_ROOTFS" = "true" ] ; then
  # Copy all prepared source files and folders to '/src'. Note that the scripts
  # will not work there because you also need proper toolchain.
  cp -r ../src src
  echo "Source files and folders have been copied to '/src'."
else
  echo "Source files and folders have been skipped."
fi

BUSYBOX_ARCH=$(file bin/busybox | cut -d' '  -f3)
if [ "$BUSYBOX_ARCH" = "64-bit" ] ; then
	[ -e "lib" ] || ln -sf lib64 lib
	FLAG64="true"
fi

mkdir -p $LIBDIR
  
if [ "$BUILD_GLIBC" = "true" ] ; then
  # This is for the dynamic loader. Note that the name and the location are both
  # specific for 32-bit and 64-bit machines. First we check the BusyBox executable
  # and then we copy the dynamic loader to its appropriate location.


    cp $SYSROOT/lib/ld-linux* $LIBDIR    
    echo "Dynamic loader is accessed via $LIBDIR."
    
  # Copy all necessary 'glibc' libraries to '/lib' BEGIN.

  # BusyBox has direct dependencies on these libraries.
  cp $SYSROOT/lib/libm.so.6 $LIBDIR
  cp $SYSROOT/lib/libc.so.6 $LIBDIR

  # These libraries are necessary for the DNS resolving.
  # cp $SYSROOT/lib/libresolv.so.2 $LIBDIR
  # cp $SYSROOT/lib/libnss_dns.so.2 $LIBDIR

  # Copy all necessary 'glibc' libraries to '/lib' END.
fi 

if [ "$MUSL_ENABLE" = "true" ] ; then
	if [ "$FLAG64" = "true" ] ; then	
		cp /lib/ld-musl-x86_64.so.1 $LIBDIR
		cd $LIBDIR
		ln -snf ld-musl-x86_64.so.1 libc.musl-x86_64.so.1
	else
		cp /lib/ld-musl-i386.so.1 $LIBDIR
		cd $LIBDIR
		ln -snf ld-musl-i386.so.1 libc.musl-x86.so.1
	fi
	cd - >/dev/null
fi

if [ "$UDEV_ENABLE" = "true" ] ; then
  # Copy all Udev files to rootfs
  cp -r $UDEV_INSTALLED/*  .
fi

echo "Install linux kernel modules."
echo $(pwd)
cp -r $KERNEL_INSTALLED/lib .

find $ROOT_DIR -type f -name ".gitignore" -delete

strip -g \
  $SRC_DIR/work/rootfs/bin/* \
  $SRC_DIR/work/rootfs/sbin/* \
  $SRC_DIR/work/rootfs/lib/* \
  2>/dev/null
echo "Reduced the size of libraries and executables."

#cp -f $SRC_DIR/minimal_config/busybox-i486-1.28.1 bin/busybox

echo "The initramfs area has been generated."

cd $SRC_DIR

echo "*** GENERATE ROOTFS END ***"
