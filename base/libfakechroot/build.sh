#!/bin/bash

VERSION=fakechroot-2.16
. ../../env.sh

BUILD_DIR=$STAGING/$VERSION
TARGET=$BUILD_DIR/libfakechroot.so

if [ -f $TARGET ]; then 
  echo "$TARGET exists -- delete it to rebuild"
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$VERSION.tar.gz
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL https://github.com/downloads/dex4er/fakechroot/${VERSION}.tar.gz
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvz $TARBALL)
else
  echo "Building cached $VERSION"
fi

(cd $BUILD_DIR; CC=$CC ./configure --host $CONFIG_HOST --build $CONFIG_BUILD)

#echo "Patching source"
patch -R $BUILD_DIR/config.h patch_config.h
patch -R $BUILD_DIR/src/glob.c patch_glob.c
patch -R $BUILD_DIR/src/libfakechroot.c patch_libfakechroot.c

#echo "Running make"
(cd $BUILD_DIR; make)

#echo "Linking SO"
(cd $BUILD_DIR; $CC -s -pie -shared -fPIC -o $TARGET -Wl,-soname,libfakechroot.so -Wl,--whole-archive $BUILD_DIR/src/.libs/libfakechroot.a -Wl,--no-whole-archive)

