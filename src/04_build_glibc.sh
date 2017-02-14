#!/bin/sh

echo "*** BUILD GLIBC BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

# Save the kernel installation directory.
KERNEL_INSTALLED=$SRC_DIR/work/kernel/kernel_installed

cd work/glibc

# Find the glibc source directory, e.g. 'glibc-2.23' and remember it.
cd $(ls -d glibc-*)
GLIBC_SRC=$(pwd)
cd ..

# Prepare the work area, e.g. 'work/glibc/glibc_objects'.
echo "Preparing glibc object area. This may take a while..."
rm -rf glibc_objects
mkdir glibc_objects

# Prepare the install area, e.g. 'work/glibc/glibc_installed'.
echo "Preparing glibc install area. This may take a while..."
rm -rf glibc_installed
mkdir glibc_installed
GLIBC_INSTALLED=$(pwd)/glibc_installed

# All glibc work is done from the working area.
cd glibc_objects

# glibc is configured to use the root folder (--prefix=) and as result all
# libraries will be installed in '/lib'. Note that on 64-bit machines BusyBox
# will be linked with the libraries in '/lib' while the Linux loader is expected
# to be in '/lib64'. Kernel headers are taken from our already prepared kernel
# header area (see xx_build_kernel.sh). Packages 'gd' and 'selinux' are disabled
# for better build compatibility with the host system.
echo "Configuring glibc...$GLIBC_OPTS"
$GLIBC_SRC/configure \
  --prefix= \
  --with-headers=$KERNEL_INSTALLED/include \
  --without-gd \
  --without-selinux \
  --disable-werror \
  CFLAGS="$CFLAGS" $GLIBC_OPTS \
  CC="gcc $COMPILE_OPTS" CXX="g++ $COMPILE_OPTS"

# Compile glibc with optimization for "parallel jobs" = "number of processors".
echo "Building glibc..."
make -j $NUM_JOBS

# Install glibc in the installation area, e.g. 'work/glibc/glibc_installed'.
echo "Installing glibc..."
make install \
  DESTDIR=$GLIBC_INSTALLED \
  -j $NUM_JOBS

cd $SRC_DIR

echo "*** BUILD GLIBC END ***"

