#!/bin/sh

echo "*** BUILD BUSYBOX BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

# Remember the glibc installation area.
GLIBC_PREPARED=$(pwd)/work/glibc/glibc_prepared

cd work/busybox

# Remove the old BusyBox install area
rm -rf busybox_installed

# Change to the source directory ls finds, e.g. 'busybox-1.24.2'.
cd $(ls -d busybox-*)

# Remove previously generated artifacts.
echo "Preparing BusyBox work area. This may take a while..."
make distclean -j $NUM_JOBS

if [ "$USE_PREDEFINED_BUSYBOX_CONFIG" = "true" -a ! -f $SRC_DIR/minimal_config/busybox.config ] ; then
  echo "Config file $SRC_DIR/minimal_config/busybox.config does not exist."
  USE_PREDEFINED_BUSYBOX_CONFIG="false"
fi

if [ "$USE_PREDEFINED_BUSYBOX_CONFIG" = "true" ] ; then
  # Use predefined configuration file for Busybox.
  echo "Using config file $SRC_DIR/minimal_config/busybox.config"  
  cp -f $SRC_DIR/minimal_config/busybox.config .config
else
  # Create default configuration file.
  echo "Generating default BusyBox configuration..."  
  make defconfig -j $NUM_JOBS
  
  # The 'inetd' applet fails to compile because we use the glibc installation area as
  # main pointer to the kernel headers (see 05_prepare_glibc.sh) and some headers are
  # not resolved. The easiest solution is to ignore this particular applet. 
  sed -i "s/.*CONFIG_INETD.*/CONFIG_INETD=n/" .config
fi

if [ $BUILD_GLIBC = true ] ; then
  echo "Build busybox from my glibc..."
  # This variable holds the full path to the glibc installation area as quoted string.
  # All back slashes are escaped (/ => \/) in order to keep the 'sed' command stable.
  GLIBC_PREPARED_ESCAPED=$(echo \"$GLIBC_PREPARED\" | sed 's/\//\\\//g')

  # Now we tell BusyBox to use the glibc prepared area.
  sed -i "s/.*CONFIG_SYSROOT.*/CONFIG_SYSROOT=$GLIBC_PREPARED_ESCAPED/" .config
else
  sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/"  .config
fi

if [  $SYSTEM_64 = false ] ; then
  echo "Build 32bit busybox..."
  sed -i "s/.*CONFIG_EXTRA_CFLAGS.*/CONFIG_EXTRA_CFLAGS=\"-m32\"/" .config
  sed -i "s/.*CONFIG_EXTRA_LDFLAGS.*/CONFIG_EXTRA_LDFLAGS=\"-m32\"/" .config
fi
# Read the 'CFLAGS' property from '.config'
CFLAGS="$(grep -i ^CFLAGS .config | cut -f2 -d'=')"

# Compile busybox with optimization for "parallel jobs" = "number of processors".
echo "Building BusyBox..."
make \
  EXTRA_CFLAGS="$CFLAGS" \
  busybox -j $NUM_JOBS

# Create the symlinks for busybox. The file 'busybox.links' is used for this.
echo "Generating BusyBox based initramfs area..."
make \
  CONFIG_PREFIX="../busybox_installed" \
  install -j $NUM_JOBS

cd $SRC_DIR

echo "*** BUILD BUSYBOX END ***"

