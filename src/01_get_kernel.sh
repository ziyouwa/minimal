#!/bin/sh

echo "*** GET KERNEL BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

# Grab everything after the last '/' character.
ARCHIVE_FILE=${KERNEL_SOURCE_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $SRC_DIR/source/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $SRC_DIR/source/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd source

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Delete object file.
  rm -f ${ARCHIVE_FILE}
  # Downloading kernel source bundle file. 
  echo "Downloading kernel source bundle from $DOWNLOAD_URL"
  curl -L $KERNEL_SOURCE_URL -o ${ARCHIVE_FILE}.down && mv ${ARCHIVE_FILE}{.down,} 
else
  echo "Using local kernel source bundle $SRC_DIR/source/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted kernel.
echo "Removing kernel work area. This may take a while..."
rm -rf ../work/kernel
mkdir ../work/kernel

# Extract kernel to folder 'work/kernel'.
# Full path will be something like 'work/kernel/linux-4.4.6'.
tar -xf $ARCHIVE_FILE -C ../work/kernel

# patching sources
cd ../work/kernel
cd $(ls -d linux-*)
for P in `ls $SRC_DIR/minimal_config/kernel_patch 2>/dev/null`
do
	echo "patching $P"
	patch -p1 <$SRC_DIR/minimal_config/kernel_patch/$P
done

cd $SRC_DIR

echo "*** GET KERNEL END ***"

