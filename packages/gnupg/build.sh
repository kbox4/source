#!/bin/bash
#https://gnupg.org/ftp/gcrypt/gnupg/gnupg-1.4.21.tar.bz2

VERSION=1.4.21
VVERSION=$VERSION
SUFFIX=tar.bz2
NAME=gnupg
DOWNLOAD_URL=https://gnupg.org/ftp/gcrypt/gnupg/$NAME-$VVERSION.$SUFFIX

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
  (cd $STAGING; tar xfvj $TARBALL)
else
  echo "Building cached $VERSION"
fi


echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic" LDFLAGS="-pie -s" LIBS="-lncurses" ./configure --host=$CONFIG_HOST --prefix=/usr)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo "Patching"

patch $BUILD_DIR/config.h patch_config.h

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi


mkdir -p $BUILD_DIR/image/

echo "Running make install"
(cd $BUILD_DIR; make DESTDIR=`pwd`/image install)

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



