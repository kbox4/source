#!/bin/bash

VNUM=3.1.2
VERSION=rsync-$VNUM

. ../../env.sh

BUILD_DIR=$STAGING/$VERSION
TARGET=$BUILD_DIR/rsync
DEB=$BUILD_DIR/${VERSION}_kbox4_${DEB_ARCH}.deb

if [ -f $DEB ]; then
  echo $DEB exists -- delete it to rebuild
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$VERSION.tar.gz
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL https://download.samba.org/pub/rsync/src/${VERSION}.tar.gz
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvz $TARBALL)
else
  echo "Building cached $VERSION"
fi


echo Running configure...

(cd $BUILD_DIR; CC=$CC CFLAGS="-fpie -fpic" LDFLAGS="-pie" ./configure --host $CONFIG_HOST --with-included-popt --with-included-zlib --prefix=/usr)

#echo "Running make"
(cd $BUILD_DIR; make)

if [[ $? -ne 0 ]] ; then
    echo make failed ... stopping
    exit 1
fi

mkdir -p $BUILD_DIR/out
mkdir -p $BUILD_DIR/image/
rm -rf $BUILD_DIR/image/*

(cd $BUILD_DIR; DESTDIR=image/ make install)

if [[ $? -ne 0 ]] ; then
    echo make install failed ... stopping
    exit 1
fi

sed -e s/%ARCH%/$DEB_ARCH/ control > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 

