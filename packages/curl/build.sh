#!/bin/bash
#https://curl.haxx.se/download/curl-7.54.0.tar.gz

VERSION=7.54.0
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=curl
DOWNLOAD_URL=https://curl.haxx.se/download/$NAME-$VVERSION.$SUFFIX

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

echo Running configure...

(cd $BUILD_DIR; CC=$CC CFLAGS="-fpie -fpic" LDFLAGS="-pie" ./configure --host $CONFIG_HOST --prefix=/usr --with-ca-bundle=/usr/share/certificates/cacert.pem)

echo "Running make"
(cd $BUILD_DIR; make)

if [[ $? -ne 0 ]] ; then
    echo make failed ... stopping
    exit 1
fi

echo "Running make install"

mkdir -p $BUILD_DIR/image
(cd $BUILD_DIR; make DESTDIR=`pwd`/image install)

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

mkdir -p $BUILD_DIR/image/usr/share/certificates/
cp cacert.pem $BUILD_DIR/image/usr/share/certificates/

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 

echo Populating sysroot

cp -pr $BUILD_DIR/image/usr/lib/* $SYSROOT/usr/lib/
cp -pr $BUILD_DIR/image/usr/include/* $SYSROOT/usr/include/


exit 0;

