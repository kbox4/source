#!/bin/bash

#http://www.eblong.com/zarf/glulx/glulxe-054.tar.gz

VERSION=0.5.4
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=glulxe
DOWNLOAD_URL=http://www.eblong.com/zarf/glulx/glulxe-054.$SUFFIX

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


echo "Patching"

patch $BUILD_DIR/Makefile patch_Makefile

echo "Running make"

(cd $BUILD_DIR; make CC=$CC OPTIONS="-g -Wall -Wmissing-prototypes -Wstrict-prototypes -Wno-unused -DOS_UNIX -fpie -fpic -pie")

mkdir -p $BUILD_DIR/image/usr/bin
$STRIP $BUILD_DIR/glulxe
cp -p $BUILD_DIR/glulxe $BUILD_DIR/image/usr/bin  

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



