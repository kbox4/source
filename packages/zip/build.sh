#!/bin/bash
#https://sourceforge.net/projects/infozip/files/Zip%203.x%20%28latest%29/3.0/zip30.tar.gz/download

VERSION=30
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=zip
DOWNLOAD_URL=https://sourceforge.net/projects/infozip/files/Zip%203.x%20%28latest%29/3.0/zip30.tar.gz/download

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}$VERSION
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
  echo "Building cached $VERSION"
fi


echo "Patching"

patch $BUILD_DIR/unix/Makefile patch_Makefile

echo "Running make"

(cd $BUILD_DIR; LOCAL_ZIP="-fpie -fpic" CFLAGS="-fpic -fpie" LFLAGS1="-pie -s" LDFLAGS="-pie -s" CC=$CC make LOCAL_ZIP="-fpie -fpic" CFLAGS="-fpic -fpie" LFLAGS1="-pie -s" LDFLAGS="-pie -s" CC=$CC -f unix/Makefile generic)

if [[ $? -ne 0 ]] ; then
    echo make failed ... stopping
    exit 1
fi

echo "Building package"
mkdir -p $BUILD_DIR/image/usr/bin
mkdir -p $BUILD_DIR/image/usr/share/man/man1
cp -p $BUILD_DIR/zip $BUILD_DIR/image/usr/bin
cp -p $BUILD_DIR/zipsplit $BUILD_DIR/image/usr/bin
cp -p $BUILD_DIR/zipcloak $BUILD_DIR/image/usr/bin
cp -p $BUILD_DIR/zipnote $BUILD_DIR/image/usr/bin
cp -p $BUILD_DIR/man/* $BUILD_DIR/image/usr/share/man/man1/

mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



