#!/bin/bash
#https://github.com/openssl/openssl/archive/OpenSSL_1_0_2a.tar.gz

VERSION=OpenSSL_1_0_2a
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=openssl
DOWNLOAD_URL=https://github.com/$NAME/$NAME/archive/$VVERSION.$SUFFIX

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

if [ $CONFIG_BUILD == "i686" ] ; then
  TARGET="android-x86" 
else
  TARGET="android-armv7" 
fi

(cd $BUILD_DIR; CC=$CC CFLAGS="-fpie -fpic" LDFLAGS="-pie" ./Configure $TARGET --prefix=/usr)

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


mkdir -p $BUILD_DIR/image/

echo "Running make install"
(cd $BUILD_DIR; make INSTALL_PREFIX=`pwd`/image install_sw)

if [[ $? -ne 0 ]] ; then
    echo make install failed ... stopping
    exit 1
fi


echo "Linking shared objects"
(cd $BUILD_DIR/image/usr/lib; $CC -s -pie -shared -fPIC -o libssl.so -Wl,-soname,libssl.so -Wl,--whole-archive libssl.a -Wl,--no-whole-archive)
(cd $BUILD_DIR/image/usr/lib; $CC -s -pie -shared -fPIC -o libcrypto.so -Wl,-soname,libcrypto.so -Wl,--whole-archive libcrypto.a -Wl,--no-whole-archive)


echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 

echo "Populating compiler sysroot"

(cd $BUILD_DIR; cp -pr image/usr/include/* $SYSROOT/usr/include/) 
(cd $BUILD_DIR; cp -pr image/usr/lib/* $SYSROOT/usr/lib/) 



