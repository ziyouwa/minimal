#!/bin/sh

echo "*** GET BUSYBOX BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

# Grab everything after the last '/' character.
ARCHIVE_FILE=${BUSYBOX_SOURCE_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $SRC_DIR/source/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $SRC_DIR/source/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd source

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Delete object file.
  rm -f ${ARCHIVE_FILE}
  # Downloading BusyBox source bundle file.
  echo "Downloading BusyBox source bundle from $DOWNLOAD_URL"
  curl  -L  $BUSYBOX_SOURCE_URL -o ${ARCHIVE_FILE}.down && mv ${ARCHIVE_FILE}{.down,} 
else
  echo "Using local BusyBox source bundle $SRC_DIR/source/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted busybox.
echo "Removing BusyBox work area. This may take a while..."
rm -rf ../work/busybox
mkdir ../work/busybox

# Extract busybox to folder 'busybox'.
# Full path will be something like 'work/busybox/busybox-1.24.2'.
tar -xf $ARCHIVE_FILE -C ../work/busybox

cd $SRC_DIR

echo "*** GET BUSYBOX END ***"

