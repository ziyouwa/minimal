#!/bin/sh

echo "*** GET BUSYBOX BEGIN ***"

SRC_DIR=$(pwd)

# Grab everything .
source $SRC_DIR/.config

# Grab everything after the last '/' character.
ARCHIVE_FILE=${EUDEV_SOURCE_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $SRC_DIR/source/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $SRC_DIR/source/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd source

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Downloading Eudev source bundle file. The '-c' option allows the download to resume.
  echo "Downloading Eudev source bundle from $DOWNLOAD_URL"
  wget -c $EUDEV_SOURCE_URL
else
  echo "Using local Eudev source bundle $SRC_DIR/source/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted eudev.
echo "Removing Eudev work area. This may take a while..."
rm -rf ../work/eudev
mkdir ../work/eudev

# Extract eudev to folder 'eudev'.
# Full path will be something like 'work/eudev/eudev-3.2.1'.
tar -xvf $ARCHIVE_FILE -C ../work/eudev

# Change to the source directory ls finds, e.g. 'eudev-1.24.2'.
cd ../work/eudev
cd $(ls -d eudev-*)
# Fix compile error,refer to https://forums.gentoo.org/viewtopic-t-1057410-start-0.html
# Patch from https://github.com/gentoo/eudev/commit/5bab4d8de0dcbb8e2e7d4d5125b4aea1652a0d60
if grep  -q ^static\ const\ struct\ key  src/udev/udev-builtin-keyboard.c  ; then
    sed -i "31d" src/udev/udev-builtin-keyboard.c  
fi
# Modify rules install directory to /etc/udev/rules.d
sed -i '/udevrulesdir/ s/udevlibexecdir\}\//sysconfdir\}\/udev\//' configure.ac

cd $SRC_DIR

echo "*** GET BUSYBOX END ***"

