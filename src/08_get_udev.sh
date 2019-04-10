#!/bin/sh

echo "*** GET UDEV BEGIN ***"

SRC_DIR=$(pwd)

# Grab everything .
source $SRC_DIR/.config

# Grab everything after the last '/' character.
ARCHIVE_FILE=${UDEV_SOURCE_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $SRC_DIR/source/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $SRC_DIR/source/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd source

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Delete object file.
  rm -f ${ARCHIVE_FILE}
  # Downloading Udev source bundle file.
  echo "Downloading Udev source bundle from $DOWNLOAD_URL"
  curl -L $UDEV_SOURCE_URL -o ${ARCHIVE_FILE}.down && mv ${ARCHIVE_FILE}{.down,} 
else
  echo "Using local Udev source bundle $SRC_DIR/source/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted udev.
echo "Removing Udev work area. This may take a while..."
rm -rf ../work/udev
mkdir ../work/udev

# Extract udev to folder 'udev'.
# Full path will be something like 'work/udev/udev-175'.
tar -xf $ARCHIVE_FILE -C ../work/udev

cd ../work/udev
cd $(ls -d udev-1*)

for F in $(ls  $SRC_DIR/minimal_config/udev*.patch)
	do
		patch -l -p1 <$F
	done
	

cd $SRC_DIR

echo "*** GET UDEV END ***"

