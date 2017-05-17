#!/bin/bash
#https://ftp.gnu.org/gnu/tar/tar-1.29.tar.xz

VERSION=1.29
VVERSION=$VERSION
SUFFIX=tar.xz
NAME=tar
DOWNLOAD_URL=https://ftp.gnu.org/gnu/tar/$NAME-$VVERSION.$SUFFIX

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
  (cd $STAGING; tar xfvJ $TARBALL)
else
  echo "Building cached $VERSION"
fi


echo Running Configure...

(cd $BUILD_DIR; CC=$CC CXX=$CXX CFLAGS="-std=c99 -fpie -fpic" CXXFLAGS="-fpie -fpic" LDFLAGS="-pie" ./configure --host=$CONFIG_HOST --prefix=/usr --with-gzip=gzip --with-bzip2=bzip2 )

if [[ $? -ne 0 ]] ; then
    echo Configure failed ... stopping
    exit 1
fi


echo "Running make"

(cd $BUILD_DIR; make CC=$CC)

if [[ $? -ne 0 ]] ; then
    echo make failed ... stopping
    exit 1
fi

echo "Running make install"

mkdir -p $BUILD_DIR/image/bin

(cd $BUILD_DIR; make CC=$CC DESTDIR=`pwd`/image install)

if [[ $? -ne 0 ]] ; then
    echo make install failed ... stopping
    exit 1
fi

cp $BUILD_DIR/image/usr/bin/tar $BUILD_DIR/image/bin/tar

echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



