#!/bin/bash
#http://github.com/kost/android-elf-cleaner/archive/master.zip

VERSION=1.0
VVERSION=$VERSION
SUFFIX=zip
NAME=android-elf-cleaner
DOWNLOAD_URL=http://github.com/kost/$NAME/archive/master.zip

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}-master
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


echo "Running make"

(cd $BUILD_DIR; make CC=$CC CXX=$CXX CFLAGS="-fpic -fpie" LDFLAGS="-pie -s")

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi

mkdir -p $BUILD_DIR/image/usr/bin
cp -p $BUILD_DIR/android-elf-cleaner $BUILD_DIR/image/usr/bin

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



