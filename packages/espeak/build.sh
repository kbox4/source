#!/bin/bash
#https://sourceforge.net/projects/espeak/files/espeak/espeak-1.48/espeak-1.48.04-source.zip/download

VERSION=1.48.04
VVERSION=$VERSION
SUFFIX=zip
NAME=espeak
DOWNLOAD_URL=https://sourceforge.net/projects/espeak/files/espeak/espeak-1.48/espeak-$VVERSION-source.$SUFFIX/download

. ../../env.sh

BUILD_DIR=$STAGING/$NAME-$VERSION-source/src
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
  (cd $STAGING; unzip $TARBALL)
else
  echo "Building cached $VERSION"
fi


echo "Patching"

patch $BUILD_DIR/Makefile patch_Makefile
patch $BUILD_DIR/speech.h patch_speech.h

echo "Running make"

(cd $BUILD_DIR; make CC=$CC CXX=$CXX CXXFLAGS="-O2 -fpic -fpie" LDFLAGS="-pie")

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi


mkdir -p $BUILD_DIR/image/

echo "Running make install"
(cd $BUILD_DIR; make DESTDIR=`pwd`/image install)

cp scripts/* $BUILD_DIR/image/usr/bin/

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



