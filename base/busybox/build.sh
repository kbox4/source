#!/bin/bash

VERSION=busybox-1.26.2

. ../../env.sh

BUILD_DIR=$STAGING/$VERSION
TARGET=$BUILD_DIR/busybox

if [ -f $TARGET ]; then
  echo $TARGET exists -- delete it to rebuild
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$VERSION.tar.bz2
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL https://busybox.net/downloads/${VERSION}.tar.bz2
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvj $TARBALL)
else
  echo "Building cached $VERSION"
fi

cp config $BUILD_DIR/.config
echo CONFIG_CROSS_COMPILER_PREFIX=\"$CC_PREFIX\" >> ${BUILD_DIR}/.config 

echo "Patching source"
patch -R $BUILD_DIR/libbb/lineedit.c patch_lineedit.c 
patch -R $BUILD_DIR/coreutils/sync.c patch_sync.c 

echo "Running make"
(cd $BUILD_DIR; make)
