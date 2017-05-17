#!/bin/bash

#http://www.eblong.com/zarf/glk/glkterm-104.tar.gz

VERSION=1.0.4
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=glkterm
DOWNLOAD_URL=http://www.eblong.com/zarf/glk/glkterm-104.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

if [ -f $DEB ]; then
  echo $DEB exists -- delete it to rebuild
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$NAME-$VERSION.$SUFFIX
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL $DOWNLOAD_URL 
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvz $TARBALL)
else
  echo "Building cached $NAME-$VERSION"
fi

echo Patching

patch $BUILD_DIR/Makefile patch_Makefile

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)


echo "Populating sysroot"
cp -p $BUILD_DIR/libglkterm.a $SYSROOT/usr/lib/
cp -p $BUILD_DIR/glk.h $SYSROOT/usr/include/
cp -p $BUILD_DIR/glkstart.h $SYSROOT/usr/include/
cp -p $BUILD_DIR/Make.glkterm $SYSROOT/usr/include/


