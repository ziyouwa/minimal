#!/bin/sh

echo "*** GENERATE ROOTFS BEGIN ***"

SRC_DIR=$(pwd)

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
KERNEL_VERSION=$(ls -d work/kernel/linux* |cut -d- -f2)

cd work

echo "Preparing initramfs work area..."
rm -rf rootfs

# Copy all BusyBox generated stuff to the location of our 'initramfs' folder.
cp -r $BUSYBOX_INSTALLED rootfs

# Copy all rootfs resources to the location of our 'initramfs' folder.
cp -r src/minimal_rootfs/* rootfs

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

if [ "$BUILD_GLIBC" = "true" ] ; then
  # This is for the dynamic loader. Note that the name and the location are both
  # specific for 32-bit and 64-bit machines. First we check the BusyBox executable
  # and then we copy the dynamic loader to its appropriate location.
  BUSYBOX_ARCH=$(file bin/busybox | cut -d' '  -f3)
  if [ "$BUSYBOX_ARCH" = "64-bit" ] ; then
    mkdir lib64
    cp $GLIBC_PREPARED/lib/ld-linux* lib64
    echo "Dynamic loader is accessed via '/lib64'."
  else
    cp $GLIBC_PREPARED/lib/ld-linux* lib
    echo "Dynamic loader is accessed via '/lib'."
  fi

  # Copy all necessary 'glibc' libraries to '/lib' BEGIN.

  # BusyBox has direct dependencies on these libraries.
  cp $GLIBC_PREPARED/lib/libm.so.6 lib
  cp $GLIBC_PREPARED/lib/libc.so.6 lib

  # These libraries are necessary for the DNS resolving.
  cp $GLIBC_PREPARED/lib/libresolv.so.2 lib
  cp $GLIBC_PREPARED/lib/libnss_dns.so.2 lib

# Copy all Udev files to rootfs
cp -r $UDEV_INSTALLED/*  .

  # Copy all necessary 'glibc' libraries to '/lib' END.
fi 

echo "Install linux kernel modules."
cp -r $KERNEL_INSTALLED/lib .

strip -g \
  $SRC_DIR/work/rootfs/bin/* \
  $SRC_DIR/work/rootfs/sbin/* \
  $SRC_DIR/work/rootfs/lib/* \
  2>/dev/null
echo "Reduced the size of libraries and executables."

echo "The initramfs area has been generated."

cd $SRC_DIR

echo "*** GENERATE ROOTFS END ***"

