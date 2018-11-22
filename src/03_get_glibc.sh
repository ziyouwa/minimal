#!/bin/sh

echo "*** GET GLIBC BEGIN ***"

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

# Grab everything after the last '/' character.
ARCHIVE_FILE=${GLIBC_SOURCE_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $SRC_DIR/source/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $SRC_DIR/source/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd source

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Delete object file.
  rm -f ${ARCHIVE_FILE}
  # Downloading glibc source bundle file. 
  echo "Downloading glibc source bundle from $DOWNLOAD_URL"
  curl -L $GLIBC_SOURCE_URL -o ${ARCHIVE_FILE}.down && mv ${ARCHIVE_FILE}{.down,} 
else
  echo "Using local glibc source bundle $SRC_DIR/source/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted glibc.
echo "Removing glibc work area. This may take a while..."
rm -rf ../work/glibc
mkdir ../work/glibc

# Extract glibc to folder 'work/glibc'.
# Full path will be something like 'work/glibc/glibc-2.23'.
tar -xf $ARCHIVE_FILE -C ../work/glibc

cd ../work/glibc
cd $( ls -d glibc-* )

for F in $(ls  $SRC_DIR/minimal_config/glibc*.patch)
	do
		patch -l -p1 <$F
	done
cd ..


cd $SRC_DIR

echo "*** GET GLIBC END ***"

