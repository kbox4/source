#!/bin/bash
#https://ftp.gnu.org/gnu/chess/gnuchess-6.2.4.tar.gz

VERSION=6.2.4
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=gnuchess
DOWNLOAD_URL=https://ftp.gnu.org/gnu/chess/$NAME-$VVERSION.$SUFFIX

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

echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-fpie -fpic" CXXFLAGS="-fpie -fpic" LDFLAGS="-pie" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --host=$CONFIG_HOST --prefix=/usr)

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi

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



