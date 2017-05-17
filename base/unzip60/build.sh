#!/bin/bash

VERSION=unzip60

. ../../env.sh

BUILD_DIR=$STAGING/$VERSION
TARGET=$BUILD_DIR/unzipsfx

if [ -f $TARGET ]; then
  echo $TARGET exists -- delete it to rebuild
  exit 0;
fi

CWD=`pwd`
if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$VERSION.zip
  if [ ! -f $TARBALL ]; then 
    echo "Unpacking $VERSION"
    (cd $STAGING; pwd; unzip $CWD/unzip60.zip) 
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; unzip $TARBALL)
else
  echo "Building cached $VERSION"
fi

cp $BUILD_DIR/unix/Makefile $BUILD_DIR/Makefile

echo "Running make"
(cd $BUILD_DIR; LOCAL_UNZIP="-fpic -fpie -DCHEAP_SFX_AUTORUN" cc=$CC CC=$CC make generic)

