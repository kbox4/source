#!/bin/bash


#http://www.cpan.org/src/5.0/perl-5.24.1.tar.gz

VERSION=5.24.1
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=perl
DOWNLOAD_URL=http://www.cpan.org/src/5.0/$NAME-$VVERSION.$SUFFIX
PATCH_URL=https://github.com/arsv/perl-cross/releases/download/1.1.3/perl-cross-1.1.3.tar.gz

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}-${VERSION}
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

if [ -f skip ]; then

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

PATCH_TARBALL=$STAGING/tarballs/perl-cross-1.1.3.tar.gz
if [ ! -f $PATCH_TARBALL ]; then
    echo "Downloading patches" 
    wget -O $PATCH_TARBALL $PATCH_URL
else
    echo Using cached patches
fi

echo "Applying perl-cross patches"
(cd $BUILD_DIR; tar zfx $PATCH_TARBALL --strip-components=1)

fi
#skip


echo "Running configure"

ANDROID=$NDK_HOME
TOOLCHAIN=$NDK
PLATFORM=$ANDROID_PLATFORM_DIR
export PATH=$PATH:$TOOLCHAIN/bin
(cd $BUILD_DIR; LDFLAGS="-pie" CFLAGS="-fpic -fpie" ./configure --target=$ANDROID_PLATFORM_NAME --prefix=/usr --sysroot=$SYSROOT)

if [[ $? -ne 0 ]] ; then
    echo configure failed ... stopping
    exit 1
fi



echo "Running make"

mkdir -p $BUILD_DIR/image/

(cd $BUILD_DIR; make -j4)

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



