#!/bin/sh

echo "*** BUILD KERNEL BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

cd work/kernel

# Prepare the kernel install area.
rm -rf kernel_installed
mkdir kernel_installed

# Change to the kernel source directory which ls finds, e.g. 'linux-4.4.6'.
cd $(ls -d linux-*)

# Cleans up the kernel sources, including configuration files.
echo "Preparing kernel work area..."
$KERNEL_MAKE mrproper -j $NUM_JOBS

if [ "$USE_PREDEFINED_KERNEL_CONFIG" = "true" -a ! -f $SRC_DIR/minimal_config/kernel.config ] ; then
  echo "Config file $SRC_DIR/minimal_config/kernel.config does not exist."
  USE_PREDEFINED_KERNEL_CONFIG="false"
fi

if [ "$USE_PREDEFINED_KERNEL_CONFIG" = "true" ] ; then
  # Use predefined configuration file for the kernel.
  echo "Using config file $SRC_DIR/minimal_config/kernel.config"  
  cp $SRC_DIR/minimal_config/kernel.config ../tmpdefconfig
  if [ "$SYSTEM_64" = "false" ] ; then
    cat $SRC_DIR/minimal_config/64_to_32_defconfig >> ../tmpdefconfig
  fi
  #mv ../tmpdefconfig .config
  scripts/kconfig/merge_config.sh $(pwd)/../tmpdefconfig
#  $KERNEL_MAKE \
#    CFLAGS="$CFLAGS" \
#    oldconfig -j $NUM_JOBS
else
  # Create default configuration file for the kernel.
  $KERNEL_MAKE defconfig -j $NUM_JOBS
  echo "Generated default kernel configuration."

  # Changes the name of the system to 'minimal'.
  sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"minimal\"/" .config

  # Enable overlay support, e.g. merge ro and rw directories.
  #sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config
  
  # Step 1 - disable all active kernel compression options (should be only one).
  sed -i "s/.*\\(CONFIG_KERNEL_.*\\)=y/\\#\\ \\1 is not set/" .config  
  
  # Step 2 - enable the 'xz' compression option.
  sed -i "s/.*CONFIG_KERNEL_XZ.*/CONFIG_KERNEL_XZ=y/" .config

  # Enable the VESA framebuffer for graphics support.
  sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config

  if [ "$USE_BOOT_LOGO" = "true" ] ; then
    sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/CONFIG_LOGO_LINUX_CLUT224=y/" .config
    echo "Boot logo is enabled."
  else
    sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/\\# CONFIG_LOGO_LINUX_CLUT224 is not set/" .config
    echo "Boot logo is disabled."
  fi
 
  # Enable the EFI stub
  #sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config

  # Check if we are building 32-bit kernel. The exit code is '1' when we are
  # building 64-bit kernel, otherwise the exit code is '0'.
  grep -q "CONFIG_X86_32=y" .config

  # The '$?' variable holds the exit code of the last issued command.
  if [ $? = 1 ] ; then
    # Enable the mixed EFI mode when building 64-bit kernel.
    echo "CONFIG_EFI_MIXED=y" >> .config
  fi
fi
 
# Disable debug symbols in kernel => smaller kernel binary.
sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config

# Compile the kernel with optimization for 'parallel jobs' = 'number of processors'.
# Good explanation of the different kernels:
# http://unix.stackexchange.com/questions/5518/what-is-the-difference-between-the-following-kernel-makefile-terms-vmlinux-vmlinux

# Install kernel headers which are used later when we build and configure the
# GNU C library (glibc).
echo "Generating kernel headers..."
$KERNEL_MAKE \
  INSTALL_HDR_PATH=$SYSROOT \
  headers_install -j $NUM_JOBS
 
echo "Building kernel..."
$KERNEL_MAKE \
  CFLAGS="$CFLAGS" \
   -j $NUM_JOBS 

# Install the kernel file.
cp arch/x86/boot/bzImage \
  $SRC_DIR/work/kernel/kernel_installed/kernel

echo "Installing kernel modules..."
$KERNEL_MAKE \
  INSTALL_MOD_PATH=$SRC_DIR/work/kernel/kernel_installed  \
  modules_install -j $NUM_JOBS

$KERNEL_MAKE \
  INSTALL_MOD_PATH=$SYSROOT  \
  modules_install -j $NUM_JOBS
rm -f ../tmpdefconfig

cd $SRC_DIR

echo "*** BUILD KERNEL END ***"

