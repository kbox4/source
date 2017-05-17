#!/bin/bash
#https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz

VERSION=2.1.8
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=libevent
DOWNLOAD_URL=https://github.com/libevent/libevent/releases/download/release-${VERSION}-stable/$NAME-${VVERSION}-stable.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/$NAME-${VERSION}-stable
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


patch $BUILD_DIR/configure patch_configure

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses" CPPLAGS="-I${SYSROOT}/usr/include/ncurses" CXXFLAGS="-fpie -fpic -I${SYSROOT}/usr/include/ncurses" LDFLAGS="-pie -s" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --host=$CONFIG_HOST --prefix=/usr)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

echo "Patching"

patch $BUILD_DIR/evutil_rand.c patch_evutil_rand.c

echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make  failed ... stopping
    exit 1
fi


mkdir -p $BUILD_DIR/image/

echo "Running make install"
(cd $BUILD_DIR; make DESTDIR=`pwd`/image install)

echo "Populating sysroot"

cp -ar $BUILD_DIR/image/usr/include/* $SYSROOT/usr/include/
cp -ar $BUILD_DIR/image/usr/lib/* $SYSROOT/usr/lib

