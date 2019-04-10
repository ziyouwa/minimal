#!/bin/sh

SRC_DIR=$(pwd)

#Grab everything from config file
source $SRC_DIR/.config

[ "$DEBUG" = "true" ] && set -xe

echo "*** CLEAN BEGIN ***"

echo "Cleaning up the main work area. This may take a while..."
rm -rf work

[ "$SYSTEM_64" = "true" ] && ( rm -rf work_64 && mkdir work_64 && ln -s work_64 work ) || ( rm -rf work_32 && mkdir work_32 && ln -s work_32 work )

# -p stops errors if the directory already exists
mkdir -p source

echo "*** CLEAN END ***"
