#!/bin/bash

VERSION=0.0.2
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=dbcmd
DOWNLOAD_URL=https://github.com/kevinboone/$NAME/archive/$VVERSION.$SUFFIX

#https://github.com/kevinboone/dbcmd/archive/v0.0.2.tar.gz

. ../../env.sh

BUILD_DIR=$STAGING/$NAME-$VERSION
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

#echo patching

#patch $BUILD_DIR/src/token.c patch_token.c

mkdir -p $BUILD_DIR/image/usr

echo "Running make"
(cd $BUILD_DIR; make CC=$CC DESTDIR=image/usr EXTRA_LIBS="-lssl -lcrypto -lz" all install)

if [[ $? -ne 0 ]] ; then
    echo make failed ... stopping
    exit 1
fi

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 

