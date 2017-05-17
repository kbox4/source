#!/bin/bash
#http://www.rarlab.com/rar/unrarsrc-5.5.3.tar.gz

VERSION=5.5.3
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=unrar
DOWNLOAD_URL=http://www.rarlab.com/rar/unrarsrc-$VVERSION.$SUFFIX

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

patch $BUILD_DIR/consio.cpp patch_consio.cpp
patch $BUILD_DIR/ulinks.cpp patch_ulinks.cpp

echo "Running make"

mkdir -p $BUILD_DIR/image/

(cd $BUILD_DIR; make CC=$CC CXX=$CXX LDFLAGS="-pie" CXXFLAGS="-fpie -fpic"  DESTDIR=`pwd`/image STRIP=$STRIP all install)

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



